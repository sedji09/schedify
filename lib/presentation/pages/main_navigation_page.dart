import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/schedule_provider.dart';
import '../../domain/entities/holiday.dart';
import 'dashboard_page.dart';
import 'weekly_schedule_page.dart';
import 'calendar_view_page.dart';
import 'notifications_ui_page.dart';
import 'schedule_form_page.dart';
import 'reminder_form_page.dart';
import 'search_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  DateTime? _calendarSelectedDate;

  List<Widget> get _pages => [
    DashboardPage(),
    WeeklySchedulePage(),
    CalendarViewPage(
      onDateSelected: (date) {
        setState(() {
          _calendarSelectedDate = date;
        });
      },
    ),
    NotificationsUiPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: const Text('Student Schedule'),
        actions: [
          if (_currentIndex == 2 && _calendarSelectedDate != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showAddHolidayDialog(context, _calendarSelectedDate!);
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScheduleFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(child: _buildNavItem(Icons.dashboard, 'Dashboard', 0)),
            Expanded(child: _buildNavItem(Icons.view_week, 'Weekly', 1)),
            const SizedBox(width: 72), // 56 (FAB) + 16 (margins) = 72 para iwas clipping!
            Expanded(child: _buildNavItem(Icons.calendar_month, 'Calendar', 2)),
            Expanded(child: _buildNavItem(Icons.notifications, 'Alerts', 3)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final color = isSelected
        ? Colors.blue
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
          if (index != 2) {
            _calendarSelectedDate = null;
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? icon : icon, color: color),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHolidayDialog(BuildContext context, DateTime selectedDate) {
    String holidayName = 'Holiday';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Holiday'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Holiday Name',
              hintText: 'e.g. Christmas, Rizal Day',
            ),
            onChanged: (val) {
              holidayName = val;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (holidayName.trim().isEmpty) holidayName = 'Holiday';
                final newHoliday = Holiday(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: holidayName,
                  date: selectedDate,
                );
                Provider.of<ScheduleProvider>(context, listen: false).addHoliday(newHoliday);
                Navigator.pop(context);
              },
              child: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      }
    );
  }
}
