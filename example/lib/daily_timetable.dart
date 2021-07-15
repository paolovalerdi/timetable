import 'package:flutter/material.dart';
import 'package:timetable/timetable.dart';
import 'package:timetable_example/pick_now_indicator.dart';

// Testing purposes only.
// This will later end up in the actual app.
class DailyTimetable<E extends Event> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timetableTheme = TimetableTheme.orDefaultOf(context);
    final eventProvider = DefaultEventProvider.of<E>(context) ?? (_) => [];
    return TimetableTheme(
      data: timetableTheme.copyWith(
        nowIndicatorStyle: timetableTheme.nowIndicatorStyle.copyWith(
          leftOffset: 8,
          shape: PickNowIndicator(leftOffset: 8),
          allowTemporalOffset: false,
        ),
        dateDividersStyle: timetableTheme.dateDividersStyle.copyWith(
          allowTemporalOffset: false,
        ),
      ),
      child: DefaultEventProvider<E>(
        eventProvider: (dates) => eventProvider(dates)
            .where((it) => it.isPartDay)
            .toList(growable: false),
        child: DatePageView(
          builder: (context, date) {
            return Row(
              children: [
                _timeIndicators(timetableTheme.timeIndicatorStyleProvider),
                SizedBox(width: 8),
                Expanded(child: _content(context, date))
              ],
            );
          },
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

  Widget _content(BuildContext context, DateTime date) {
    final events =
        DefaultEventProvider.of<E>(context)?.call(date.fullDayInterval) ?? [];
    return TimeZoom(
      child: HourDividers(
        child: _wrapWithNowIndicatorIf(
          isToday: date.atStartOfDay == DateTimeTimetable.today(),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: DateDividers(
              child: DateContent<E>(
                date: date,
                events: events,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapWithNowIndicatorIf({
    required bool isToday,
    required Widget child,
  }) {
    if (isToday) {
      return NowIndicator(child: child);
    }
    return child;
  }
}
