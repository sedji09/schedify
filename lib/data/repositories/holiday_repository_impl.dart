import '../../domain/entities/holiday.dart';
import '../../domain/repositories/holiday_repository.dart';
import '../models/holiday_model.dart';
import 'package:hive/hive.dart';

class HolidayRepositoryImpl implements HolidayRepository {
  final Box<HolidayModel> holidayBox;

  HolidayRepositoryImpl(this.holidayBox);

  @override
  Future<List<Holiday>> getHolidays() async {
    return holidayBox.values.toList();
  }

  @override
  Future<void> addHoliday(Holiday holiday) async {
    final model = HolidayModel.fromEntity(holiday);
    await holidayBox.put(model.id, model);
  }

  @override
  Future<void> deleteHoliday(String id) async {
    await holidayBox.delete(id);
  }
}
