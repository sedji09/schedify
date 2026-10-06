import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class AddSchedule {
  final ScheduleRepository repository;

  AddSchedule(this.repository);

  Future<void> call(Schedule schedule) async {
    return await repository.addSchedule(schedule);
  }
}
