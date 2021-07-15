import 'dart:math';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supercharged/supercharged.dart';
import 'package:timetable/timetable.dart';
import 'package:timetable_example/daily_timetable.dart';
import 'package:timetable_example/pick_now_indicator.dart';
import 'package:timetable_example/weekly_timetable.dart';

import 'timetable_date_header.dart';

DateTime mondayUtc() {
  final today = DateTime.now().copyWith(isUtc: true).atStartOfDay;
  return today - (today.weekday - 1).days;
}

DateTime saturdayUtc() {
  final monday = mondayUtc();
  return monday + 5.days;
}

enum TimetableViewMode { daily, weekly }

extension TimetableViewModeExtension on TimetableViewMode {
  bool get isDaily => this == TimetableViewMode.daily;

  bool get isWeekly => this == TimetableViewMode.weekly;

  VisibleDateRange get visibleDateRange {
    switch (this) {
      case TimetableViewMode.daily:
        return VisibleDateRange.days(
          1,
          minDate: mondayUtc(),
          maxDate: saturdayUtc(),
        );
      case TimetableViewMode.weekly:
        return VisibleDateRange.fixed(
          mondayUtc(),
          6,
        );
    }
  }

  IconData get toggleIcon {
    switch (this) {
      case TimetableViewMode.daily:
        return Icons.view_week_outlined;
      case TimetableViewMode.weekly:
        return Icons.view_day_outlined;
    }
  }

  TimetableViewMode get inverseMode {
    switch (this) {
      case TimetableViewMode.daily:
        return TimetableViewMode.weekly;
      case TimetableViewMode.weekly:
        return TimetableViewMode.daily;
        break;
    }
  }
}

class Playground extends StatefulWidget {
  const Playground({
    Key? key,
    this.initialViewMode = TimetableViewMode.daily,
  }) : super(key: key);

  final TimetableViewMode initialViewMode;

  @override
  _PlaygroundState createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> with TickerProviderStateMixin {
  late DateController _dateController;
  late TimeController _timeController;
  late TimetableViewMode _viewMode = widget.initialViewMode;

  @override
  void initState() {
    super.initState();
    _timeController = TimeController(
      initialRange: TimeRange(6.5.hours, 18.5.hours),
    );
    _dateController = DateController(
      visibleRange: _viewMode.visibleDateRange,
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TimetableConfig<BasicEvent>(
      dateController: _dateController,
      timeController: _timeController,
      eventProvider: eventProviderFromFixedList(_dummyEvents()),
      eventBuilder: (context, event) => BasicEventWidget(event),
      theme: TimetableThemeData(
        context,
        startOfWeek: DateTime.monday,
        timeIndicatorStyleProvider: (time) => TimeIndicatorStyle(
          context,
          time,
          width: 52,
          textAlign: TextAlign.right,
          label: DateFormat.j('en').format(DateTime(0) + time),
          alwaysUse24HourFormat: false,
        ),
        nowIndicatorStyle: NowIndicatorStyle(
          context,
          lineColor: Colors.black,
        ),
      ),
      child: Column(
        children: [
          _fakeAppbar(),
          Expanded(child: _timetable(context)),
        ],
      ),
    );
  }

  Widget _fakeAppbar() {
    return Material(
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: Text('Horario'),
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  _viewMode.toggleIcon,
                ),
                onPressed: () {
                  setState(() {
                    _viewMode = _viewMode.inverseMode;
                    _dateController.visibleRange = _viewMode.visibleDateRange;
                    _dateController.animateToToday(
                      vsync: this,
                      duration: 450.milliseconds,
                    );
                  });
                },
              )
            ],
          ),
          SizedBox(
            height: 32,
            child: DailyTimetableDateHeader(viewMode: _viewMode),
          ),
        ],
      ),
    );
  }

  Widget _timetable(BuildContext context) {
    return _viewMode.isWeekly
        ? WeeklyTimetable<BasicEvent>()
        : DailyTimetable<BasicEvent>();
  }

  List<BasicEvent> _dummyEvents() {
    final monday = mondayUtc();
    return List.generate(7, (index) {
      return BasicEvent(
        id: index,
        title: '$index',
        backgroundColor: _getColor('$index'),
        start: (monday + index.days).copyWith(hour: (12 + index)),
        end: (monday + index.days).copyWith(hour: (12 + index), minute: 59),
      );
    });
  }

  Color _getColor(String id) {
    return Random(id.hashCode)
        .nextColorHsv(saturation: 0.6, value: 0.8, alpha: 1)
        .toColor();
  }
}
