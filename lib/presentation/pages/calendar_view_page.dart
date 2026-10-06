import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/schedule_provider.dart';
import '../widgets/schedule_card.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/holiday.dart';

class CalendarViewPage extends StatefulWidget {
  final Function(DateTime?)? onDateSelected;

  const CalendarViewPage({Key? key, this.onDateSelected}) : super(key: key);

  @override
  State<CalendarViewPage> createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  PageController? _pageController;

  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  bool _isAnniversary(DateTime holidayDate, DateTime date) {
    return holidayDate.month == date.month && holidayDate.day == date.day;
  }

  DayOfWeek _getDateTimeDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday: return DayOfWeek.monday;
      case DateTime.tuesday: return DayOfWeek.tuesday;
      case DateTime.wednesday: return DayOfWeek.wednesday;
      case DateTime.thursday: return DayOfWeek.thursday;
      case DateTime.friday: return DayOfWeek.friday;
      case DateTime.saturday: return DayOfWeek.saturday;
      case DateTime.sunday: return DayOfWeek.sunday;
      default: return DayOfWeek.monday;
    }
  }

  List<Schedule> _getEventsForDay(DateTime day, ScheduleProvider provider) {
    final isHoliday = provider.holidays.any((h) => _isAnniversary(h.date, day));
    if (isHoliday) return [];

    final dayOfWeek = _getDateTimeDayOfWeek(day);
    final schedules = provider.schedules.where((s) {
      if (s.day != dayOfWeek) return false;
      final isExcluded = s.excludedDates.any((d) => isSameDay(d, day));
      return !isExcluded;
    }).toList();

    schedules.sort((a, b) {
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });

    return schedules;
  }

  int _calculateSelectedRow(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstDayOffset = firstDayOfMonth.weekday % 7; // Sunday = 0
    final dayOffset = firstDayOffset + date.day - 1;
    return dayOffset ~/ 7;
  }

  Widget _buildCustomHeader() {
    final String monthName = _monthNames[_focusedDay.month - 1];

    return SizedBox(
      height: 90.0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 48.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      _pageController?.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                  Text(
                    '$monthName ${_focusedDay.year}',
                    style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      _pageController?.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(color: Colors.grey, fontSize: 13.0, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        final activeDate = (_selectedDay != null &&
                _selectedDay!.month == _focusedDay.month &&
                _selectedDay!.year == _focusedDay.year)
            ? _selectedDay!
            : _focusedDay;

        final selectedRow = _calculateSelectedRow(activeDate);

        final selectedSchedules = _selectedDay != null
            ? _getEventsForDay(_selectedDay!, provider)
            : _getEventsForDay(_focusedDay, provider);

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _CalendarHeaderDelegate(
                headerBuilder: (context) => _buildCustomHeader(),
                headerHeight: 90.0,
                selectedRow: selectedRow,
                rowHeight: 52.0,
                calendarBuilder: (context) => TableCalendar<Schedule>(
                  firstDay: DateTime.utc(2020, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  headerVisible: false,
                  daysOfWeekVisible: false,
                  sixWeekMonthsEnforced: true,
                  rowHeight: 52.0,
                  onCalendarCreated: (controller) => _pageController = controller,
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: (day) => _getEventsForDay(day, provider),
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = null;
                        _focusedDay = focusedDay;
                      });
                      widget.onDateSelected?.call(null);
                    } else {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      widget.onDateSelected?.call(selectedDay);
                    }
                  },
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    markerDecoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, date, events) {
                      final isToday = isSameDay(date, DateTime.now());
                      return Container(
                        margin: const EdgeInsets.all(6.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isToday ? Colors.blue : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isToday ? null : Border.all(color: Colors.blue, width: 2.0),
                        ),
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isToday ? Colors.white : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    todayBuilder: (context, date, events) {
                      return Container(
                        margin: const EdgeInsets.all(6.0),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    markerBuilder: (context, date, events) {
                      final isHoliday = provider.holidays.any((h) => _isAnniversary(h.date, date));
                      if (isHoliday) {
                        return Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            width: 16.0,
                            height: 16.0,
                            child: const Center(
                              child: Icon(
                                Icons.celebration,
                                color: Colors.white,
                                size: 10.0,
                              ),
                            ),
                          ),
                        );
                      }

                      if (events.isNotEmpty) {
                        return Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blueAccent,
                            ),
                            width: 16.0,
                            height: 16.0,
                            child: Center(
                              child: Text(
                                '${events.length}',
                                style: const TextStyle().copyWith(
                                  color: Colors.white,
                                  fontSize: 10.0,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  final currentDate = _selectedDay ?? _focusedDay;
                  final isHoliday = provider.holidays.any((h) => _isAnniversary(h.date, currentDate));
                  if (isHoliday) {
                    final h = provider.holidays.firstWhere((h) => _isAnniversary(h.date, currentDate));
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.celebration, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${h.name}',
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                            onPressed: () {
                              final h = provider.holidays.firstWhere((h) => _isAnniversary(h.date, currentDate));
                              provider.deleteHoliday(h.id);
                            },
                          )
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 0.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ScheduleCard(
                      schedule: selectedSchedules[index],
                      selectedDate: _selectedDay ?? _focusedDay,
                    );
                  },
                  childCount: selectedSchedules.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CalendarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget Function(BuildContext context) headerBuilder;
  final Widget Function(BuildContext context) calendarBuilder;
  final int selectedRow;
  final double rowHeight;
  final double headerHeight;

  _CalendarHeaderDelegate({
    required this.headerBuilder,
    required this.calendarBuilder,
    required this.selectedRow,
    this.rowHeight = 52.0,
    this.headerHeight = 90.0,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double maxGridHeight = 6 * rowHeight;
    final double minGridHeight = rowHeight;
    
    final double progress = (shrinkOffset / (maxGridHeight - minGridHeight)).clamp(0.0, 1.0);
    
    // Clamp the currentGridHeight to prevent negative BoxConstraints when scrolling 
    // past the min extent of the sliver (e.g. overscroll bouncing).
    final double currentGridHeight = (maxGridHeight - shrinkOffset).clamp(minGridHeight, maxGridHeight);
    final double dy = -selectedRow * rowHeight * progress;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          headerBuilder(context),
          ClipRect(
            child: SizedBox(
              height: currentGridHeight,
              child: OverflowBox(
                minHeight: maxGridHeight,
                maxHeight: maxGridHeight,
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: Offset(0, dy),
                  child: calendarBuilder(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => headerHeight + 6 * rowHeight;

  @override
  double get minExtent => headerHeight + rowHeight;

  @override
  bool shouldRebuild(covariant _CalendarHeaderDelegate oldDelegate) {
    return true; // Builders can capture new state, so we always rebuild when a new delegate is provided
  }
}
