import 'package:hive/hive.dart';
import '../models/schedule_model.dart';

abstract class LocalScheduleDataSource {
  Future<List<ScheduleModel>> getSchedules();
  Future<void> addSchedule(ScheduleModel schedule);
  Future<void> updateSchedule(ScheduleModel schedule);
  Future<void> deleteSchedule(String id);
  Future<List<ScheduleModel>> searchSchedules(String query);
}

class HiveScheduleDataSourceImpl implements LocalScheduleDataSource {
  final Box<ScheduleModel> scheduleBox;

  HiveScheduleDataSourceImpl(this.scheduleBox);

  @override
  Future<List<ScheduleModel>> getSchedules() async {
    return scheduleBox.values.toList();
  }

  @override
  Future<void> addSchedule(ScheduleModel schedule) async {
    await scheduleBox.put(schedule.id, schedule);
  }

  @override
  Future<void> updateSchedule(ScheduleModel schedule) async {
    await scheduleBox.put(schedule.id, schedule);
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await scheduleBox.delete(id);
  }

  @override
  Future<List<ScheduleModel>> searchSchedules(String query) async {
    final lowerQuery = query.toLowerCase();
    return scheduleBox.values.where((s) {
      return s.subject.toLowerCase().contains(lowerQuery) ||
          s.professor.toLowerCase().contains(lowerQuery) ||
          s.room.toLowerCase().contains(lowerQuery) ||
          s.notes.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
