import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
    const [DeviceOrientation.portraitUp],
  );
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(const CalendarApp());
}

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'التقويم',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        canvasColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          surface: Colors.black,
          onSurface: Colors.white,
          primary: Colors.white,
          onPrimary: Colors.black,
        ),
        splashFactory: NoSplash.splashFactory,
      ),
      home: const CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const _months = <String>[
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

  static const _weekdays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    final today = _today();
    _visibleMonth = DateTime(today.year, today.month);
    _selectedDay = today;
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + delta,
      );

      final maxDay = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + 1,
        0,
      ).day;

      if (_selectedDay.day > maxDay) {
        _selectedDay = DateTime(
          _visibleMonth.year,
          _visibleMonth.month,
          maxDay,
        );
      }
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = day;
      // Tapping a leading/trailing date moves the calendar into that month.
      _visibleMonth = DateTime(day.year, day.month);
    });
  }

  void _goToToday() {
    final today = _today();
    setState(() {
      _visibleMonth = DateTime(today.year, today.month);
      _selectedDay = today;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime day) => _isSameDay(day, _today());

  @override
  Widget build(BuildContext context) {
    final year = _visibleMonth.year;
    final month = _visibleMonth.month;
    final firstDayOffset = DateTime(year, month, 1).weekday - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          children: [
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('calendarTitleButton'),
                    onTap: _goToToday,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: Text(
                        'التقويم',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  key: const Key('previousMonthButton'),
                  onPressed: () => _changeMonth(-1),
                  tooltip: 'Previous month',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                ),
                IconButton(
                  key: const Key('nextMonthButton'),
                  onPressed: () => _changeMonth(1),
                  tooltip: 'Next month',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_months[month - 1]} $year',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _weekdays
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            color: Color(0xFF8A8A8A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final rowHeight = constraints.maxHeight / 6;
                  return GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 42,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisExtent: rowHeight,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                    itemBuilder: (context, index) {
                      // DateTime normalizes out-of-range days into adjacent months.
                      final day = DateTime(
                        year,
                        month,
                        index - firstDayOffset + 1,
                      );
                      final dayNumber = day.day;
                      final inVisibleMonth =
                          day.year == year && day.month == month;
                      final selected = _isSameDay(day, _selectedDay);
                      final today = _isToday(day);

                      return Center(
                        child: Semantics(
                          button: true,
                          label:
                              '${_months[day.month - 1]} $dayNumber, ${day.year}',
                          selected: selected,
                          child: InkWell(
                            key: Key(
                              'calendarDay-${day.year}-${day.month}-${day.day}',
                            ),
                            borderRadius: BorderRadius.circular(26),
                            onTap: () => _selectDay(day),
                            child: Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: today && !selected
                                    ? Border.all(
                                        color: const Color(0xFF777777),
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Text(
                                '$dayNumber',
                                style: TextStyle(
                                  color: selected
                                      ? Colors.black
                                      : inVisibleMonth
                                          ? Colors.white
                                          : const Color(0xFF777777),
                                  fontSize: 15,
                                  fontWeight: selected || today
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
