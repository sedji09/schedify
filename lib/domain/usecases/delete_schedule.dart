import '../repositories/schedule_repository.dart';

class DeleteSchedule {
  final ScheduleRepository repository;

  DeleteSchedule(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteSchedule(id);
  }
}
