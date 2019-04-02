import 'dart:html';

class TioOverlayService {
  HtmlElement containerElement;

  TioOverlayService()
      : containerElement = DivElement()..id = "popup-container" {
    document.querySelector("head").append(
        StyleElement()
          ..text =
          '''#popup-container {
                  position: absolute;
                  top: 0;
                  left: 0;
                  width: 100%;
                  height: 100%;
                  pointer-events: none;
               }
               
               #popup-container > .pane {
                  pointer-events: auto;
                  position: absolute;
               }
            '''
    );
    document.querySelector('body').append(containerElement);
  }

  void register(HtmlElement element) {
    containerElement.append(element);
  }
}
