import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:timetable/timetable.dart';

class PickNowIndicator extends NowIndicatorShape {
  PickNowIndicator({
    this.color = Colors.black,
    this.accentColor = Colors.white,
    this.radius = 4.5,
    this.leftOffset = 0,
  }) : _paint = Paint()..color = color;

  final Color color;
  final Color accentColor;
  final double radius;
  final double leftOffset;
  final Paint _paint;

  @override
  void paint(
    Canvas canvas,
    Size size,
    double dateStartOffset,
    double dateEndOffset,
    double timeOffset,
  ) {
    final actualSize = (radius * 2);
    final left = dateStartOffset.coerceAtLeast(radius);
    final arcRadius = Radius.circular(actualSize);
    canvas.drawPath(
      Path()
        ..moveTo(left, timeOffset - actualSize / 2)
        ..arcToPoint(Offset(left + actualSize, timeOffset), radius: arcRadius)
        ..arcToPoint(
          Offset(left, timeOffset + actualSize / 2),
          radius: arcRadius,
        )
        ..close(),
      _paint,
    );
    canvas.drawCircle(
      Offset(dateStartOffset.coerceAtLeast(leftOffset), timeOffset),
      radius,
      _paint,
    );
    canvas.drawCircle(
      Offset(dateStartOffset.coerceAtLeast(leftOffset), timeOffset),
      (radius / 2).round().toDouble(),
      Paint()..color = accentColor,
    );
  }

  @override
  PickNowIndicator copyWith({Color? color, double? radius}) {
    return PickNowIndicator(
      color: color ?? this.color,
      radius: radius ?? this.radius,
    );
  }

  @override
  int get hashCode => hashValues(color, radius);

  @override
  bool operator ==(Object other) {
    return other is PickNowIndicator &&
        color == other.color &&
        radius == other.radius;
  }
}
