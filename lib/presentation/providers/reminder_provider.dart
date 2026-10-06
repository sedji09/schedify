import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/reminder.dart';
import '../../data/models/reminder_model.dart';
import '../../core/services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final Box<ReminderModel> reminderBox;
  final LocalNotificationService notificationService;
  
  List<Reminder> _reminders = [];
  List<Reminder> get reminders => _reminders;

  ReminderProvider({
    required this.reminderBox,
    required this.notificationService,
  }) {
    loadReminders();
  }

  void loadReminders() {
    _reminders = reminderBox.values.map((model) => model.toEntity()).toList();
    _reminders.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    notifyListeners();
  }

  Future<void> addReminder(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await reminderBox.put(reminder.id, model);
    
    await notificationService.scheduleNotification(
      id: reminder.id.hashCode,
      title: reminder.title,
      body: reminder.description.isNotEmpty ? reminder.description : 'Custom Reminder',
      scheduledDate: reminder.scheduledDate,
    );
    
    loadReminders();
  }

  Future<void> deleteReminder(String id) async {
    await reminderBox.delete(id);
    await notificationService.cancelNotification(id.hashCode);
    loadReminders();
  }

  Future<void> toggleCompleted(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final old = _reminders[index];
      final updated = Reminder(
        id: old.id,
        title: old.title,
        description: old.description,
        scheduledDate: old.scheduledDate,
        isCompleted: !old.isCompleted,
      );
      final model = ReminderModel.fromEntity(updated);
      await reminderBox.put(id, model);
      
      if (updated.isCompleted) {
        await notificationService.cancelNotification(id.hashCode);
      } else {
        await notificationService.scheduleNotification(
          id: updated.id.hashCode,
          title: updated.title,
          body: updated.description.isNotEmpty ? updated.description : 'Custom Reminder',
          scheduledDate: updated.scheduledDate,
        );
      }
      
      loadReminders();
    }
  }
}
