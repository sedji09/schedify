import 'package:flutter/material.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/usecases/get_schedules.dart';
import '../../domain/usecases/add_schedule.dart';
import '../../domain/usecases/update_schedule.dart';
import '../../domain/usecases/delete_schedule.dart';
import '../../domain/usecases/search_schedules.dart';
import '../../domain/entities/holiday.dart';
import '../../domain/repositories/holiday_repository.dart';
import '../../core/services/notification_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final GetSchedules getSchedulesUseCase;
  final AddSchedule addScheduleUseCase;
  final UpdateSchedule updateScheduleUseCase;
  final DeleteSchedule deleteScheduleUseCase;
  final SearchSchedules searchSchedulesUseCase;
  final HolidayRepository holidayRepository;
  final LocalNotificationService notificationService;

  List<Schedule> _schedules = [];
  List<Schedule> get schedules => _schedules;

  List<Schedule> _searchResults = [];
  List<Schedule> get searchResults => _searchResults;

  List<Holiday> _holidays = [];
  List<Holiday> get holidays => _holidays;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  ScheduleProvider({
    required this.getSchedulesUseCase,
    required this.addScheduleUseCase,
    required this.updateScheduleUseCase,
    required this.deleteScheduleUseCase,
    required this.searchSchedulesUseCase,
    required this.holidayRepository,
    required this.notificationService,
  });

  Future<void> fetchSchedules() async {
    _isLoading = true;
    notifyListeners();
    _schedules = await getSchedulesUseCase();
    _holidays = await holidayRepository.getHolidays();
    _isLoading = false;
    notifyListeners();
  }

  void toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    if (enabled) {
      for (var schedule in _schedules) {
        await _scheduleClassNotification(schedule);
      }
    } else {
      for (var schedule in _schedules) {
        for (int i = 0; i < 4; i++) {
          await notificationService.cancelNotification(('class_${schedule.id}_$i').hashCode);
        }
      }
    }
  }

  Future<void> addHoliday(Holiday holiday) async {
    _isLoading = true;
    notifyListeners();
    await holidayRepository.addHoliday(holiday);
    await fetchSchedules();
  }

  Future<void> deleteHoliday(String id) async {
    _isLoading = true;
    notifyListeners();
    await holidayRepository.deleteHoliday(id);
    await fetchSchedules();
  }

  Future<void> addSchedule(Schedule schedule) async {
    _isLoading = true;
    notifyListeners();
    await addScheduleUseCase(schedule);
    await _scheduleClassNotification(schedule);
    await fetchSchedules();
  }

  Future<void> updateSchedule(Schedule schedule) async {
    _isLoading = true;
    notifyListeners();
    await updateScheduleUseCase(schedule);
    await _scheduleClassNotification(schedule);
    await fetchSchedules();
  }

  Future<void> deleteSchedule(String id) async {
    _isLoading = true;
    notifyListeners();
    await deleteScheduleUseCase(id);
    await notificationService.cancelNotification(('class_$id').hashCode);
    await fetchSchedules();
  }

  Future<void> _scheduleClassNotification(Schedule schedule) async {
    // Schedule for the next upcoming day of week
    final now = DateTime.now();
    
    // Find next date that matches schedule.day
    DateTime nextDate = DateTime(now.year, now.month, now.day, schedule.startTime.hour, schedule.startTime.minute);
    
    // Adjust to 15 mins before
    nextDate = nextDate.subtract(const Duration(minutes: 15));

    // Move to next matching weekday
    while (nextDate.weekday != (schedule.day.index + 1) || nextDate.isBefore(now)) {
      nextDate = nextDate.add(const Duration(days: 1));
    }

    // Schedule weekly notification
    if (!_notificationsEnabled) return;

    for (int i = 0; i < 4; i++) {
      final scheduledFor = nextDate.add(Duration(days: 7 * i));
      
      // Skip if it's a holiday or excluded date
      final isExcluded = schedule.excludedDates.any((d) => 
        d.year == scheduledFor.year && d.month == scheduledFor.month && d.day == scheduledFor.day);
      final isHoliday = holidays.any((h) => 
        h.date.year == scheduledFor.year && h.date.month == scheduledFor.month && h.date.day == scheduledFor.day);
      
      if (!isExcluded && !isHoliday) {
        await notificationService.scheduleNotification(
          id: ('class_${schedule.id}_$i').hashCode,
          title: 'Upcoming Class: ${schedule.subject}',
          body: '${schedule.subject} with ${schedule.professor} starts in 15 mins at ${schedule.room}',
          scheduledDate: scheduledFor,
        );
      }
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = await searchSchedulesUseCase(query);
    }
    notifyListeners();
  }
}
