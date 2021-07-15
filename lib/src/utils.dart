import 'package:dart_date/dart_date.dart' show Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:supercharged/supercharged.dart';

import 'week.dart';

export 'package:dart_date/dart_date.dart' show Interval;
export 'package:supercharged/supercharged.dart';

export 'utils/listenable.dart';
export 'utils/size_reporting_widget.dart';

extension DoubleTimetable on double {
  double coerceAtLeast(double min) => this < min ? min : this;
  double coerceAtMost(double max) => this > max ? max : this;
  double coerceIn(double min, double max) =>
      coerceAtLeast(min).coerceAtMost(max);
}

extension ComparableTimetable<T extends Comparable<T>> on T {
  bool operator <(T other) => compareTo(other) < 0;
  bool operator <=(T other) => compareTo(other) <= 0;
  bool operator >(T other) => compareTo(other) > 0;
  bool operator >=(T other) => compareTo(other) >= 0;

  T coerceAtLeast(T min) => (this < min) ? min : this;
  T coerceAtMost(T max) => this > max ? max : this;
  T coerceIn(T min, T max) => coerceAtLeast(min).coerceAtMost(max);
}

typedef MonthWidgetBuilder = Widget Function(
  BuildContext context,
  DateTime month,
);
typedef WeekWidgetBuilder = Widget Function(BuildContext context, Week week);
typedef DateWidgetBuilder = Widget Function(
  BuildContext context,
  DateTime date,
);

extension DateTimeTimetable on DateTime {
  static DateTime date(int year, [int month = 1, int day = 1]) {
    final date = DateTime.utc(year, month, day);
    assert(date.isValidTimetableDate);
    return date;
  }

  static DateTime month(int year, int month) {
    final date = DateTime.utc(year, month, 1);
    assert(date.isValidTimetableMonth);
    return date;
  }

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    bool? isUtc,
  }) {
    return InternalDateTimeTimetable.create(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      millisecond: millisecond ?? this.millisecond,
      isUtc: isUtc ?? this.isUtc,
    );
  }

  Duration get timeOfDay => difference(atStartOfDay);

  DateTime get atStartOfDay =>
      copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
  bool get isAtStartOfDay => this == atStartOfDay;
  DateTime get atEndOfDay =>
      copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);
  bool get isAtEndOfDay => this == atEndOfDay;

  static DateTime now() {
    final date = DateTime.now().copyWith(isUtc: true);
    assert(date.isValidTimetableDateTime);
    return date;
  }

  static DateTime today() {
    final date = DateTimeTimetable.now().atStartOfDay;
    assert(date.isValidTimetableDate);
    return date;
  }

  static DateTime currentMonth() {
    final month = DateTimeTimetable.today().firstDayOfMonth;
    assert(month.isValidTimetableMonth);
    return month;
  }

  bool get isToday => atStartOfDay == DateTimeTimetable.today();

  Interval get interval => Interval(atStartOfDay, atEndOfDay);
  Interval get fullDayInterval {
    assert(isValidTimetableDate);
    return Interval(this, atEndOfDay);
  }

  DateTime nextOrSame(int dayOfWeek) {
    assert(isValidTimetableDate);
    assert(weekday.isValidTimetableDayOfWeek);

    return this + ((dayOfWeek - weekday) % DateTime.daysPerWeek).days;
  }

  DateTime previousOrSame(int weekday) {
    assert(isValidTimetableDate);
    assert(weekday.isValidTimetableDayOfWeek);

    return this - ((this.weekday - weekday) % DateTime.daysPerWeek).days;
  }

  int get daysInMonth {
    final february = isLeapYear ? 29 : 28;
    final index = this.month - 1;
    return [31, february, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][index];
  }

  DateTime get firstDayOfMonth => atStartOfDay.copyWith(day: 1);
  DateTime get lastDayOfMonth => copyWith(day: daysInMonth);

  DateTime roundTimeToMultipleOf(Duration duration) {
    assert(duration.isValidTimetableTimeOfDay);
    return atStartOfDay + duration * (timeOfDay / duration).floor();
  }

  double get page {
    assert(isValidTimetableDateTime);
    return millisecondsSinceEpoch / Duration.millisecondsPerDay;
  }

  int get datePage {
    assert(isValidTimetableDate);
    return page.floor();
  }

  static DateTime dateFromPage(int page) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      (page * Duration.millisecondsPerDay).toInt(),
      isUtc: true,
    );
    assert(date.isValidTimetableDate);
    return date;
  }

  static DateTime dateTimeFromPage(double page) {
    return DateTime.fromMillisecondsSinceEpoch(
      (page * Duration.millisecondsPerDay).toInt(),
      isUtc: true,
    );
  }
}

extension InternalDateTimeTimetable on DateTime {
  static DateTime create({
    required int year,
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    bool isUtc = true,
  }) {
    if (isUtc) {
      return DateTime.utc(year, month, day, hour, minute, second, millisecond);
    }
    return DateTime(year, month, day, hour, minute, second, millisecond);
  }

  bool operator <(DateTime other) => isBefore(other);
  bool operator <=(DateTime other) =>
      isBefore(other) || isAtSameMomentAs(other);
  bool operator >(DateTime other) => isAfter(other);
  bool operator >=(DateTime other) => isAfter(other) || isAtSameMomentAs(other);

  static final List<int> innerDateHours =
      List.generate(Duration.hoursPerDay - 1, (i) => i + 1);
}

extension NullableDateTimeTimetable on DateTime? {
  bool get isValidTimetableDateTime => this == null || this!.isUtc;
  bool get isValidTimetableDate =>
      isValidTimetableDateTime && (this == null || this!.isAtStartOfDay);
  bool get isValidTimetableMonth =>
      isValidTimetableDate && (this == null || this!.day == 1);
}

extension NullableDurationTimetable on Duration? {
  bool get isValidTimetableTimeOfDay =>
      this == null || (0.days <= this! && this! <= 1.days);
}

extension NullableIntTimetable on int? {
  bool get isValidTimetableDayOfWeek =>
      this == null || (DateTime.monday <= this! && this! <= DateTime.sunday);
  bool get isValidTimetableMonth =>
      this == null || (1 <= this! && this! <= DateTime.monthsPerYear);
}

extension IntervalTimetable on Interval {
  bool intersects(Interval other) => start <= other.end && end >= other.start;

  Interval get dateInterval {
    final interval = Interval(
      start.atStartOfDay,
      (end - 1.milliseconds).atEndOfDay,
    );
    assert(interval.isValidTimetableDateInterval);
    return interval;
  }
}

extension NullableIntervalTimetable on Interval? {
  bool get isValidTimetableInterval {
    if (this == null) return true;
    return this!.start.isValidTimetableDateTime &&
        this!.end.isValidTimetableDateTime;
  }

  bool get isValidTimetableDateInterval {
    return isValidTimetableInterval &&
        (this == null ||
            (this!.start.isValidTimetableDate && this!.end.isAtEndOfDay));
  }
}
