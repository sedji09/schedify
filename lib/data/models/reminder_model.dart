import 'package:hive/hive.dart';
import '../../domain/entities/reminder.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 2)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime scheduledDate;

  @HiveField(4)
  final bool isCompleted;

  ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.isCompleted,
  });

  factory ReminderModel.fromEntity(Reminder entity) {
    return ReminderModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      scheduledDate: entity.scheduledDate,
      isCompleted: entity.isCompleted,
    );
  }

  Reminder toEntity() {
    return Reminder(
      id: id,
      title: title,
      description: description,
      scheduledDate: scheduledDate,
      isCompleted: isCompleted,
    );
  }
}
