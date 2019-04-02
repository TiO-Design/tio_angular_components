import 'dart:html';
import 'dart:math';

import 'package:angular/angular.dart';

abstract class TioPopupSource {
  Rectangle get dimensions;
}

class ElementPopupSource implements TioPopupSource {
  final Element _sourceElement;

  ElementPopupSource(this._sourceElement);

  @override
  Rectangle get dimensions => _sourceElement.getBoundingClientRect();

  Element get sourceElement => _sourceElement;
}

// TODO: What does exportAs do?
@Directive(selector: "[popup-source]", exportAs: "popup-source")
class PopupSourceDirective extends ElementPopupSource {
  PopupSourceDirective(Element element) : super(element);
}
