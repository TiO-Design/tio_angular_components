import 'dart:math';

import 'package:meta/meta.dart';

abstract class Alignment {
  num calcLeft(Rectangle<num> source, Rectangle<num> content);

  num calcTop(Rectangle<num> source, Rectangle<num> content);
}

class AlignmentEnd implements Alignment {
  const AlignmentEnd();

  @override
  num calcLeft(Rectangle<num> source, Rectangle<num> content) =>
      source.left + source.width - content.width;

  @override
  num calcTop(Rectangle<num> source, Rectangle<num> content) =>
      source.top + source.height - content.height;
}

class AlignmentStart implements Alignment {
  const AlignmentStart();

  @override
  num calcLeft(Rectangle<num> source, Rectangle<num> content) => source.left;

  @override
  num calcTop(Rectangle<num> source, Rectangle<num> content) => source.top;
}

class AlignmentCenter implements Alignment {
  const AlignmentCenter();

  @override
  num calcLeft(Rectangle<num> source, Rectangle<num> content) =>
      source.left + (source.width / 2) - (content.width / 2);

  @override
  num calcTop(Rectangle<num> source, Rectangle<num> content) =>
      source.top + (source.height / 2) - (content.height / 2);
}

class AlignmentBefore implements Alignment {
  const AlignmentBefore();

  @override
  num calcLeft(Rectangle<num> source, Rectangle<num> content) =>
      source.left - content.width;

  @override
  num calcTop(Rectangle<num> source, Rectangle<num> content) =>
      source.top - content.height;
}

class AlignmentAfter implements Alignment {
  const AlignmentAfter();

  @override
  num calcLeft(Rectangle<num> source, Rectangle<num> content) =>
      source.left + source.width;

  @override
  num calcTop(Rectangle<num> source, Rectangle<num> content) =>
      source.top + source.height;
}

class RelativePosition {
  static const adjacentLeftTop = RelativePosition(
      xAlignment: AlignmentBefore(), yAlignment: AlignmentStart());

  static const adjacentLeftBottom = RelativePosition(
      xAlignment: AlignmentBefore(), yAlignment: AlignmentEnd());

  static const adjacentRightTop = RelativePosition(
      xAlignment: AlignmentAfter(), yAlignment: AlignmentStart());

  static const adjacentRightBottom = RelativePosition(
      xAlignment: AlignmentAfter(), yAlignment: AlignmentEnd());

  Point<num> align(Rectangle<num> source, Rectangle<num> content) => Point<num>(
      this.xAlignment.calcLeft(source, content),
      this.yAlignment.calcTop(source, content));

  final Alignment xAlignment;
  final Alignment yAlignment;

  const RelativePosition(
      {@required this.xAlignment, @required this.yAlignment});
}
