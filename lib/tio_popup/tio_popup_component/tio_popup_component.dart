import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:angular/angular.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:tio_angular_components/tio_popup/alignment.dart';
import 'package:tio_angular_components/tio_popup/tio_overlay_service.dart';
import 'package:tio_angular_components/tio_popup/tio_popup_hierarchy.dart';
import 'package:tio_angular_components/tio_popup/tio_popup_source.dart';

@Component(
    selector: "tio-popup",
    templateUrl: "tio_popup_component.html",
    styleUrls: ["tio_popup_component.css"])
class TioPopupComponent with TioPopupHierarchyElement implements OnDestroy {
  /// The last known size of the viewport.
  ///
  /// The top/left of this [Rectangle] is always (0, 0). A Rectangle returned by
  /// getBoundingClientRect() will be positioned relative to this point (i.e.
  /// will be in the viewport vector space).
  static MutableRectangle _viewportRect;

  final log = Logger("${TioPopupComponent}");

  final TioOverlayService _overlayService;
  final TioPopupHierarchy _hierarchy;

  /// The view container of [this].
  final ViewContainerRef _viewContainer;
  final NgZone _ngZone;
  HtmlElement _popupElement;
  Element _positionedElement;
  Element _backgroundElement;
  bool _viewInitialized = false;
  bool _isOpening = false;

  final onVisibleController = StreamController<bool>();

  // -----
  // Constructors
  // -----

  TioPopupComponent(this._viewContainer, this._overlayService, this._hierarchy,
      this._ngZone) {
    _initViewportRect();
  }

  // -----
  // Inputs
  // -----

  @Input()
  set visible(bool visible) {
    if (visible) {
      if (!_viewInitialized) {
        _initView();
      }
      _open();
    } else if (_viewInitialized) {
      _close();
    }
  }

  @Input()
  TioPopupSource source;

  @Input()
  bool autoDismiss = true;

  @Input()
  bool constrainToViewPort = true;

  @Input()
  List<RelativePosition> preferredPositions;

  // -----
  // Outputs
  // -----

  @Output("visibleChange")
  Stream<bool> get onVisible => onVisibleController.stream;

  // -----
  // View children
  // -----

  @ViewChild("background")
  TemplateRef backgroundRef;

  @ViewChild("positioned")
  TemplateRef positionedRef;

  void _initView() {
    log.finest("In _initView");

    assert(_viewInitialized == false);

    _positionedElement = DivElement()
      ..style.position = "absolute"
      ..style.zIndex = 2.toString();

    _backgroundElement = DivElement()
      ..style.position = "absolute"
      ..style.zIndex = 1.toString()
      ..style.pointerEvents = "none";

    _popupElement = DivElement()
      ..classes.add("pane")
      ..style.display = "none";

    final positionedView = _viewContainer.createEmbeddedView(positionedRef);
    positionedView.rootNodes.forEach((node) => _positionedElement.append(node));

    final backgroundView = _viewContainer.createEmbeddedView(backgroundRef);
    backgroundView.rootNodes.forEach((node) => _backgroundElement.append(node));

    _popupElement.append(_positionedElement);
    _popupElement.append(_backgroundElement);

    _overlayService.register(_popupElement);

    _viewInitialized = true;
  }

  void _open() {
    log.finest("In _open");

    // Avoid duplicate events.
    if (_isOpening) return;
    _isOpening = true;

    if (!_viewInitialized) {
      throw StateError('No content is attached.');
    } else if (source == null) {
      throw StateError('Cannot open popup: no source set.');
    }

    _popupElement
      ..style.removeProperty("display")
      ..style.visibility = "hidden";

    _reposition();

    _popupElement..style.visibility = "visible";

    attachToVisibleHierarchy();

    onVisibleController.add(true);
  }

  void _close() {
    log.finest("In _close");

    if (!_isOpening) return;
    _isOpening = false;

    _popupElement..style.display = "none";
    detachFromVisibleHierarchy();

    onVisibleController.add(false);
  }

  // -----
  // Popup hierarchy stuff
  // -----

  @override
  TioPopupHierarchy get hierarchy => _hierarchy;

  @override
  bool get shouldAutoDismiss => autoDismiss;

  @override
  HtmlElement get popupElement => _popupElement;

  @override
  List<Element> get autoDismissBlockers {
    var sourceElement = source is ElementPopupSource
        ? (source as ElementPopupSource).sourceElement
        : null;
    return sourceElement != null ? [sourceElement] : [];
  }

  @override
  void onDismiss() {
    log.finest("In onDismiss");

    _close();
  }

  void _initViewportRect() {
    // The reason a separate variable is maintained instead of using
    // window.innerWidth/window.innerHeight directly is because accessing
    // window.innerWidth/window.innerHeight can cause reflows.
    _viewportRect =
        MutableRectangle(0, 0, window.innerWidth, window.innerHeight);

    _ngZone.runOutsideAngular(() {
      window.onResize.listen((_) {
        _viewportRect.width = window.innerWidth;
        _viewportRect.height = window.innerHeight;
      });
    });
  }

  void _reposition() {
    final popupPosition = _calcBestPosition(
        container: _viewportRect,
        content: _positionedElement.getBoundingClientRect(),
        relativePositions: preferredPositions,
        source: source.dimensions);

    final alignedPopupRect = popupPosition.alignRectangle(
        source.dimensions, _positionedElement.getBoundingClientRect());

    var popupRect = alignedPopupRect;

    if (constrainToViewPort) {
      popupRect = _shiftRectangleToFitWithin(alignedPopupRect, _viewportRect);
    }

    _positionedElement
      ..style.top = "${popupRect.top}px"
      ..style.left = "${popupRect.left}px";
  }

  @override
  void ngOnDestroy() {
    _popupElement.remove();
  }
}

RelativePosition _calcBestPosition(
    {@required Rectangle<num> container,
    @required Rectangle<num> source,
    @required Rectangle<num> content,
    @required List<RelativePosition> relativePositions}) {
  assert(relativePositions != null && relativePositions.isNotEmpty,
      "No relative positions provided.");

  var bestPosition = relativePositions.first;
  double bestOverlap = 0.0;

  for (var relativePosition in relativePositions) {
    final alignedContent = relativePosition.alignRectangle(source, content);

    if (container.containsRectangle(alignedContent)) return relativePosition;

    final overlapRect = container.intersection(alignedContent);
    final overlapArea = overlapRect.width * overlapRect.height;

    if (overlapArea > bestOverlap) {
      bestOverlap = overlapArea.toDouble();
      bestPosition = relativePosition;
    }
  }

  return bestPosition;
}

/// Returns a new [Rectangle] with the same dimensions as [rect] that got
/// repositioned to fit into [container] entirely.
///
/// If [rect] is larger than the container, this function will prefer to keep
/// the top left corner visible.
///
Rectangle<num> _shiftRectangleToFitWithin(
    Rectangle<num> rect, Rectangle<num> container) {
  num left = rect.left;
  num top = rect.top;
  if (rect.left < container.left) {
    left = container.left;
  } else if (rect.right > container.right) {
    left = container.right - rect.width;
  }
  if (rect.top < container.top) {
    top = container.top;
  } else if (rect.bottom > container.bottom) {
    top = container.bottom - rect.height;
  }
  return Rectangle(left.round(), top.round(), rect.width, rect.height);
}
