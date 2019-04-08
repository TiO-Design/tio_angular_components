import 'dart:html';

import 'package:angular/di.dart';
import 'package:tio_angular_components/tio_popup/tio_popup_hierarchy.dart';

const overlayProviders = [
  ClassProvider(TioOverlayService),
  ClassProvider(TioPopupHierarchy)
];

class TioOverlayService {
  final HtmlElement _overlayContainerElement;

  TioOverlayService()
      : _overlayContainerElement = DivElement()
    ..classes.add("overlay-container") {
    final headElement = document.querySelector("head");
    final bodyElement = document.querySelector("body");

    final overlayContainerStyle = StyleElement()
      ..text = '''.overlay-container {
                  position: absolute;
                  top: 0;
                  left: 0;
                  width: 100%;
                  height: 100%;
                  pointer-events: none;
                  z-index: 1000000;
               }
               
               .overlay-container > .pane {
                  pointer-events: auto;
                  position: absolute;
               }
            ''';

    headElement.append(overlayContainerStyle);
    bodyElement.append(_overlayContainerElement);
  }

  /// Places [element] inside [_overlayContainerElement].
  void register(HtmlElement element) =>
      _overlayContainerElement.append(element);
}
