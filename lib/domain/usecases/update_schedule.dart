import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class UpdateSchedule {
  final ScheduleRepository repository;

  UpdateSchedule(this.repository);

  Future<void> call(Schedule schedule) async {
    return await repository.updateSchedule(schedule);
  }
}
