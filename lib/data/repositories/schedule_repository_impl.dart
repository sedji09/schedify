import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/hive_schedule_data_source.dart';
import '../models/schedule_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final LocalScheduleDataSource dataSource;

  ScheduleRepositoryImpl(this.dataSource);

  @override
  Future<List<Schedule>> getSchedules() async {
    return await dataSource.getSchedules();
  }

  @override
  Future<void> addSchedule(Schedule schedule) async {
    await dataSource.addSchedule(ScheduleModel.fromEntity(schedule));
  }

  @override
  Future<void> updateSchedule(Schedule schedule) async {
    await dataSource.updateSchedule(ScheduleModel.fromEntity(schedule));
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await dataSource.deleteSchedule(id);
  }

  @override
  Future<List<Schedule>> searchSchedules(String query) async {
    return await dataSource.searchSchedules(query);
  }
}
