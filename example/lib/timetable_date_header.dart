import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetable/timetable.dart';
import 'package:timetable_example/playground.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class DailyTimetableDateHeader extends StatelessWidget {
  const DailyTimetableDateHeader({
    Key? key,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.weekendColor = Colors.red,
    required this.viewMode,
  }) : super(key: key);

  final Color activeColor;
  final Color inactiveColor;
  final Color weekendColor;
  final TimetableViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    if (viewMode.isWeekly) {
      return Row(
        children: [
          SizedBox(width: 52 + 16),
          Expanded(
            child: DatePageView(
              builder: (_, date) => WeeklyDateHeader(
                date: date,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                weekendColor: weekendColor,
              ),
            ),
          ),
          SizedBox(width: 20)
        ],
      );
    }
    return DatePageView(
      builder: (_, date) => DailyDateHeader(
        date: date,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        weekendColor: weekendColor,
      ),
    );
  }
}

class DailyDateHeader extends StatelessWidget {
  const DailyDateHeader({
    Key? key,
    required this.date,
    required this.activeColor,
    required this.inactiveColor,
    required this.weekendColor,
  }) : super(key: key);

  final DateTime date;
  final Color activeColor;
  final Color inactiveColor;
  final Color weekendColor;

  @override
  Widget build(BuildContext context) {
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    final isToday = date.atStartOfDay == DateTimeTimetable.today();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(width: 52 + 16),
        SizedBox(height: 8, child: VerticalDivider(width: 0)),
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 17,
                top: 3,
              ),
              child: Text(
                DateFormat(DateFormat.WEEKDAY).format(date).capitalize(),
                style: Theme.of(context).textTheme.button?.copyWith(
                      color: isToday
                          ? activeColor
                          : (isWeekend ? weekendColor : inactiveColor),
                    ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8, child: VerticalDivider(width: 0)),
      ],
    );
  }
}

class WeeklyDateHeader extends StatelessWidget {
  const WeeklyDateHeader({
    Key? key,
    required this.date,
    required this.activeColor,
    required this.inactiveColor,
    required this.weekendColor,
  }) : super(key: key);

  final DateTime date;
  final Color activeColor;
  final Color inactiveColor;
  final Color weekendColor;

  @override
  Widget build(BuildContext context) {
    final isWeekend = date.weekday == DateTime.saturday;
    final isToday = date.atStartOfDay == DateTimeTimetable.today();
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 0,
          bottom: 0,
          height: 8,
          child: VerticalDivider(width: 0),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 3,
          ),
          child: Text(
            DateFormat(DateFormat.WEEKDAY)
                .format(date)
                .capitalize()
                .substring(0, 2),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.button?.copyWith(
                  color: isToday
                      ? activeColor
                      : (isWeekend ? weekendColor : inactiveColor),
                ),
          ),
        ),
        if (isWeekend)
          Positioned(
            right: 0,
            bottom: 0,
            height: 8,
            child: VerticalDivider(width: 0),
          )
      ],
    );
  }
}
