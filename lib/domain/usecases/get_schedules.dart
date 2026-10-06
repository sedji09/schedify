import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class GetSchedules {
  final ScheduleRepository repository;

  GetSchedules(this.repository);

  Future<List<Schedule>> call() async {
    return await repository.getSchedules();
  }
}
