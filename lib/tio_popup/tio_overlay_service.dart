import 'dart:html';

class TioOverlayService {
  HtmlElement containerElement;

  TioOverlayService()
      : containerElement = DivElement()..id = "popup-container" {
    document.querySelector('body').append(containerElement);
  }

  void register(HtmlElement element) {
    containerElement.append(element);
  }
}
