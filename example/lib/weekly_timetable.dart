import 'package:flutter/material.dart';
import 'package:timetable/timetable.dart';
import 'package:timetable_example/pick_now_indicator.dart';

// Testing purposes only.
// This will later end up in the actual app.
class WeeklyTimetable<E extends Event> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timetableTheme = TimetableTheme.orDefaultOf(context);
    final eventProvider = DefaultEventProvider.of<E>(context) ?? (_) => [];
    return TimetableTheme(
      data: timetableTheme.copyWith(
        nowIndicatorStyle: timetableTheme.nowIndicatorStyle.copyWith(
          leftOffset: 8,
          shape: PickNowIndicator(leftOffset: 8)
        ),
      ),
      child: DefaultEventProvider<E>(
        eventProvider: (dates) => eventProvider(dates)
            .where((it) => it.isPartDay)
            .toList(growable: false),
        child: Row(
          children: [
            _timeIndicators(timetableTheme.timeIndicatorStyleProvider),
            SizedBox(width: 8),
            Expanded(child: _content(context)),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _timeIndicators(
    TimeBasedStyleProvider<TimeIndicatorStyle> timeIndicatorStyleProvider,
  ) {
    return TimeZoom(
      child: TimeIndicators.hours(
        styleProvider: timeIndicatorStyleProvider,
      ),
    );
  }

  Widget _content(BuildContext context) {
    return TimeZoom(
      child: HourDividers(
        child: NowIndicator(
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: DateDividers(
              child: DatePageView(
                builder: (_, date) {
                  final events = DefaultEventProvider.of<E>(context)
                          ?.call(date.fullDayInterval) ??
                      [];
                  return DateContent<E>(
                    date: date,
                    events: events,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
