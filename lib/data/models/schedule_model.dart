import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/schedule.dart';

class ScheduleModel extends Schedule {
  ScheduleModel({
    required super.id,
    required super.subject,
    required super.professor,
    required super.room,
    required super.day,
    required super.startTime,
    required super.endTime,
    required super.color,
    super.notes,
    super.excludedDates,
  });

  factory ScheduleModel.fromEntity(Schedule schedule) {
    return ScheduleModel(
      id: schedule.id,
      subject: schedule.subject,
      professor: schedule.professor,
      room: schedule.room,
      day: schedule.day,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      color: schedule.color,
      notes: schedule.notes,
      excludedDates: schedule.excludedDates,
    );
  }
}

class ScheduleModelAdapter extends TypeAdapter<ScheduleModel> {
  @override
  final int typeId = 0;

  @override
  ScheduleModel read(BinaryReader reader) {
    final model = ScheduleModel(
      id: reader.read() as String,
      subject: reader.read() as String,
      professor: reader.read() as String,
      room: reader.read() as String,
      day: DayOfWeek.values[reader.read() as int],
      startTime: TimeOfDay(hour: reader.read() as int, minute: reader.read() as int),
      endTime: TimeOfDay(hour: reader.read() as int, minute: reader.read() as int),
      color: Color(reader.read() as int),
      notes: reader.read() as String,
    );
    
    if (reader.availableBytes > 0) {
      final count = reader.read() as int;
      final List<DateTime> excludedDates = [];
      for (int i = 0; i < count; i++) {
        excludedDates.add(DateTime.fromMillisecondsSinceEpoch(reader.read() as int));
      }
      return ScheduleModel(
        id: model.id,
        subject: model.subject,
        professor: model.professor,
        room: model.room,
        day: model.day,
        startTime: model.startTime,
        endTime: model.endTime,
        color: model.color,
        notes: model.notes,
        excludedDates: excludedDates,
      );
    }
    
    return model;
  }

  @override
  void write(BinaryWriter writer, ScheduleModel obj) {
    writer.write(obj.id);
    writer.write(obj.subject);
    writer.write(obj.professor);
    writer.write(obj.room);
    writer.write(obj.day.index);
    writer.write(obj.startTime.hour);
    writer.write(obj.startTime.minute);
    writer.write(obj.endTime.hour);
    writer.write(obj.endTime.minute);
    writer.write(obj.color.value);
    writer.write(obj.notes);
    writer.write(obj.excludedDates.length);
    for (final date in obj.excludedDates) {
      writer.write(date.millisecondsSinceEpoch);
    }
  }
}
