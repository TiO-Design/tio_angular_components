import 'dart:math';

import 'package:meta/meta.dart';

abstract class Alignment {
  double align(Edge<num> source, Edge<num> content);
}

class AlignmentEnd implements Alignment {
  const AlignmentEnd();

  @override
  double align(Edge<num> source, Edge<num> content) =>
      source.point + source.length - content.length;
}

class AlignmentStart implements Alignment {
  const AlignmentStart();

  @override
  double align(Edge<num> source, Edge<num> content) => source.point;
}

class AlignmentCenter implements Alignment {
  const AlignmentCenter();

  @override
  double align(Edge<num> source, Edge<num> content) =>
      source.point + (source.length / 2) - (content.length / 2);
}

class AlignmentBefore implements Alignment {
  const AlignmentBefore();

  @override
  double align(Edge<num> source, Edge<num> content) =>
      source.point - content.length;
}

class AlignmentAfter implements Alignment {
  const AlignmentAfter();

  @override
  double align(Edge<num> source, Edge<num> content) =>
      source.point + source.length;
}

class RelativePosition {
  static const adjacentInline = [
    adjacentRightTop,
    adjacentLeftTop,
    adjacentRightBottom,
    adjacentRightTop
  ];

  static const adjacentLeftTop = RelativePosition(
      xAlignment: AlignmentBefore(), yAlignment: AlignmentStart());

  static const adjacentLeftBottom = RelativePosition(
      xAlignment: AlignmentBefore(), yAlignment: AlignmentEnd());

  static const adjacentRightTop = RelativePosition(
      xAlignment: AlignmentAfter(), yAlignment: AlignmentStart());

  static const adjacentRightBottom = RelativePosition(
      xAlignment: AlignmentAfter(), yAlignment: AlignmentEnd());

  Rectangle<num> alignRectangle(Rectangle<num> source,
      Rectangle<num> content) =>
      Rectangle(
          this.xAlignment.align(
              Edge.topFromRectangle(source), Edge.topFromRectangle(content)),
          this.yAlignment.align(
              Edge.leftFromRectangle(source), Edge.leftFromRectangle(content)),
          content.width,
          content.height);

  final Alignment xAlignment;
  final Alignment yAlignment;

  const RelativePosition({@required this.xAlignment, @required this.yAlignment});
}

class Edge<T extends num> {
  final T point;
  final T length;

  Edge({@required this.point, @required this.length});

  factory Edge.leftFromRectangle(Rectangle<T> rectangle) =>
      Edge<T>(point: rectangle.top, length: rectangle.height);

  factory Edge.topFromRectangle(Rectangle<T> rectangle) =>
      Edge<T>(point: rectangle.left, length: rectangle.width);
}
