import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:logging/logging.dart';
import 'package:tio_angular_components/tio_popup/tio_overlay_service.dart';
import 'package:tio_angular_components/tio_popup/tio_popup_hierarchy.dart';
import 'package:tio_angular_components/tio_popup/tio_popup_source.dart';

@Component(
    selector: "tio-popup",
    templateUrl: "tio_popup_component.html",
    styleUrls: ["tio_popup_component.css"])
class TioPopupComponent with TioPopupHierarchyElement {
  final log = Logger("${TioPopupComponent}");

  final TioOverlayService _overlayService;
  final TioPopupHierarchy _hierarchy;

  /// The view container of [this].
  final ViewContainerRef _viewContainer;
  HtmlElement _popupElement;
  bool _viewInitialized = false;
  int _uniqueId = 0;
  bool _isOpening = false;

  final onVisibleController = StreamController<bool>();

  // -----
  // Constructors
  // -----

  TioPopupComponent(this._viewContainer, this._overlayService, this._hierarchy);

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

  // -----
  // Outputs
  // -----

  @Output("visibleChange")
  Stream<bool> get onVisible => onVisibleController.stream;

  // -----
  // View children
  // -----

  @ViewChild("template")
  TemplateRef templateRef;

  void _initView() {
    log.finest("In _initView");

    assert(_viewInitialized == false);

    _popupElement = DivElement()
      ..id = "popup-${_uniqueId++}"
      ..classes.add("pane")
      ..style.display = "none";

    var view = _viewContainer.createEmbeddedView(templateRef);
    view.rootNodes.forEach(((node) => _popupElement.append(node)));

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
      ..style.top = "${source.dimensions.top + source.dimensions.height}px"
      ..style.left = "${source.dimensions.left + source.dimensions.width}px";

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
}
