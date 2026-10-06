import 'package:hive/hive.dart';
import '../../domain/entities/holiday.dart';

class HolidayModel extends Holiday {
  HolidayModel({
    required super.id,
    required super.name,
    required super.date,
  });

  factory HolidayModel.fromEntity(Holiday holiday) {
    return HolidayModel(
      id: holiday.id,
      name: holiday.name,
      date: holiday.date,
    );
  }
}

class HolidayModelAdapter extends TypeAdapter<HolidayModel> {
  @override
  final int typeId = 1;

  @override
  HolidayModel read(BinaryReader reader) {
    return HolidayModel(
      id: reader.read() as String,
      name: reader.read() as String,
      date: DateTime.fromMillisecondsSinceEpoch(reader.read() as int),
    );
  }

  @override
  void write(BinaryWriter writer, HolidayModel obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.date.millisecondsSinceEpoch);
  }
}
