import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calender/main.dart';

void main() {
  const months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  testWidgets(
    'renders current month, navigates, and title returns to today',
    (tester) async {
      await tester.pumpWidget(const CalendarApp());

      final now = DateTime.now();
      expect(
        find.text('${months[now.month - 1]} ${now.year}'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('calendarTitleButton')), findsOneWidget);
      expect(find.byKey(const Key('previousMonthButton')), findsOneWidget);
      expect(find.byKey(const Key('nextMonthButton')), findsOneWidget);

      await tester.tap(find.byKey(const Key('nextMonthButton')));
      await tester.pump();

      final nextMonth = DateTime(now.year, now.month + 1);
      expect(
        find.text('${months[nextMonth.month - 1]} ${nextMonth.year}'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('calendarTitleButton')));
      await tester.pump();

      expect(
        find.text('${months[now.month - 1]} ${now.year}'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows dates before day one and opens the adjacent month when tapped',
    (tester) async {
      await tester.pumpWidget(const CalendarApp());

      final now = DateTime.now();
      var targetMonth = DateTime(now.year, now.month);
      var firstDayOffset =
          DateTime(targetMonth.year, targetMonth.month, 1).weekday - 1;

      // Pick a month with leading dates, regardless of when CI runs.
      for (var i = 0; i < 12 && firstDayOffset == 0; i++) {
        await tester.tap(find.byKey(const Key('nextMonthButton')));
        await tester.pump();
        targetMonth = DateTime(targetMonth.year, targetMonth.month + 1);
        firstDayOffset =
            DateTime(targetMonth.year, targetMonth.month, 1).weekday - 1;
      }

      expect(firstDayOffset, greaterThan(0));
      final precedingDates = List<DateTime>.generate(
        firstDayOffset,
        (index) => DateTime(
          targetMonth.year,
          targetMonth.month,
          1 - firstDayOffset + index,
        ),
      );

      for (final date in precedingDates) {
        expect(
          find.byKey(
            Key('calendarDay-${date.year}-${date.month}-${date.day}'),
          ),
          findsOneWidget,
          reason: 'The leading date $date should appear before day 1.',
        );
      }

      final tappedDate = precedingDates.first;
      await tester.tap(
        find.byKey(
          Key(
            'calendarDay-${tappedDate.year}-${tappedDate.month}-${tappedDate.day}',
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('${months[tappedDate.month - 1]} ${tappedDate.year}'),
        findsOneWidget,
      );
      expect(
        find.byKey(
          Key(
            'calendarDay-${tappedDate.year}-${tappedDate.month}-${tappedDate.day}',
          ),
        ),
        findsOneWidget,
      );
    },
  );
}
