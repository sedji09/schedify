import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

class SearchSchedules {
  final ScheduleRepository repository;

  SearchSchedules(this.repository);

  Future<List<Schedule>> call(String query) async {
    return await repository.searchSchedules(query);
  }
}
