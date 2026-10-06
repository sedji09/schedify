import '../entities/holiday.dart';

abstract class HolidayRepository {
  Future<List<Holiday>> getHolidays();
  Future<void> addHoliday(Holiday holiday);
  Future<void> deleteHoliday(String id);
}
