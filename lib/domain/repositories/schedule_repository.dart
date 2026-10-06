import '../entities/schedule.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getSchedules();
  Future<void> addSchedule(Schedule schedule);
  Future<void> updateSchedule(Schedule schedule);
  Future<void> deleteSchedule(String id);
  Future<List<Schedule>> searchSchedules(String query);
}
