import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';

import '../config.dart';
import '../localization.dart';
import '../theme.dart';
import '../utils.dart';
import 'time_indicators.dart';

/// A widget that displays a label at the given time.
///
/// See also:
///
/// * [TimeIndicators], which positions [TimeIndicator] widgets.
/// * [TimeIndicatorStyle], which defines visual properties (including the
///   label) for this widget.
/// * [TimetableTheme] (and [TimetableConfig]), which provide styles to
///   descendant Timetable widgets.
class TimeIndicator extends StatelessWidget {
  TimeIndicator({
    Key? key,
    required this.time,
    this.style,
  })  : assert(time.isValidTimetableTimeOfDay),
        super(key: key);

  static String formatHour(Duration time) => _format(DateFormat.j(), time);
  static String formatHourMinute(Duration time) =>
      _format(DateFormat.jm(), time);
  static String formatHourMinuteSecond(Duration time) =>
      _format(DateFormat.jms(), time);

  static String formatHour24(Duration time) => _format(DateFormat.H(), time);
  static String formatHour24Minute(Duration time) =>
      _format(DateFormat.Hm(), time);
  static String formatHour24MinuteSecond(Duration time) =>
      _format(DateFormat.Hms(), time);

  static String _format(DateFormat format, Duration time) {
    assert(time.isValidTimetableTimeOfDay);
    return format.format(DateTime(0) + time);
  }

  final Duration time;
  final TimeIndicatorStyle? style;

  @override
  Widget build(BuildContext context) {
    final style = this.style ??
        TimetableTheme.orDefaultOf(context).timeIndicatorStyleProvider(time);

    return Container(
      width: style.width,
      height: style.height,
      margin: style.margin,
      child: Text(
        style.label,
        style: style.textStyle,
        textAlign: style.textAlign,
      ),
    );
  }
}

/// Defines visual properties for [TimeIndicator].
///
/// See also:
///
/// * [TimetableThemeData], which bundles the styles for all Timetable widgets.
@immutable
class TimeIndicatorStyle {
  factory TimeIndicatorStyle(
    BuildContext context,
    Duration time, {
    TextStyle? textStyle,
    String? label,
    EdgeInsets? margin,
    double? width,
    double? height,
    TextAlign? textAlign,
    bool alwaysUse24HourFormat = false,
  }) {
    assert(time.isValidTimetableTimeOfDay);

    final theme = context.theme;
    final caption = theme.textTheme.caption!;
    final proportionalFiguresFeature = FontFeature.proportionalFigures().value;
    return TimeIndicatorStyle.raw(
      textStyle: textStyle ??
          caption.copyWith(
            color: theme.colorScheme.background.disabledOnColor,
            fontFeatures: [
              ...?caption.fontFeatures
                  ?.where((it) => it.value != proportionalFiguresFeature),
              FontFeature.tabularFigures(),
            ],
          ),
      label: label ??
          () {
            context.dependOnTimetableLocalizations();
            return alwaysUse24HourFormat
                ? TimeIndicator.formatHour24(time)
                : TimeIndicator.formatHour(time);
          }(),
      margin: margin,
      width: width,
      height: height,
      textAlign: textAlign,
    );
  }

  const TimeIndicatorStyle.raw({
    required this.textStyle,
    required this.label,
    this.margin,
    this.width,
    this.height,
    this.textAlign,
  });

  final TextStyle textStyle;
  final String label;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final TextAlign? textAlign;

  TimeIndicatorStyle copyWith({
    TextStyle? textStyle,
    String? label,
    EdgeInsets? margin,
    double? width,
    double? height,
    TextAlign? textAlign,
  }) {
    return TimeIndicatorStyle.raw(
      textStyle: textStyle ?? this.textStyle,
      label: label ?? this.label,
      margin: margin ?? this.margin,
      width: width ?? this.width,
      height: height ?? this.height,
      textAlign: textAlign ?? this.textAlign,
    );
  }

  @override
  int get hashCode => hashValues(textStyle, label);
  @override
  bool operator ==(Object other) {
    return other is TimeIndicatorStyle &&
        textStyle == other.textStyle &&
        label == other.label;
  }
}
