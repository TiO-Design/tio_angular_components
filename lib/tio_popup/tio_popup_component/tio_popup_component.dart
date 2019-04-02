import 'dart:async';
import 'dart:developer';
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

  // Whether the popup is in the process of opening (or has finished opening).
  //
  // If true, then the popup is in the process of opening, or is already open.
  // This means that [_open] has already been called, and subsequent calls to
  // [_open] should be a no-op.
  //
  // If false, then the popup is in the process of closing, or is already
  // closed. This means that [_close] has already been called, and subsequent
  // calls to [_close] should be a no-op.
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
  Element source;

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

    _popupElement = DivElement()..id = "popup-${_uniqueId++}";

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
    }
    /*else if (source != null) {
      throw StateError('Cannot open popup: no source set.');
    }*/

    _popupElement.style.display =
    "initial"; // TODO: Change to something different.

    // TODO: Just a quick and dirty fix so that the popup does not close instantly after open because of autoDismiss.
    Future.delayed(Duration(milliseconds: 10), () {
      attachToVisibleHierarchy();
    });

    onVisibleController.add(true);
  }

  void _close() {
    log.finest("In _close");
    if (!_isOpening) return;
    _isOpening = false;

    _popupElement.style.display = "none";
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
  List<Element> get autoDismissBlockers => [source];

  @override
  void onDismiss() {
    log.finest("In onDismiss");
    _close();
  }
}
