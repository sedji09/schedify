import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/reminder_provider.dart';
import '../providers/schedule_provider.dart';
import 'reminder_form_page.dart';

class NotificationsUiPage extends StatefulWidget {
  const NotificationsUiPage({Key? key}) : super(key: key);

  @override
  State<NotificationsUiPage> createState() => _NotificationsUiPageState();
}

class _NotificationsUiPageState extends State<NotificationsUiPage> {
  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final scheduleProvider = Provider.of<ScheduleProvider>(context);

    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Enable Class Notifications'),
          subtitle: const Text('Receive reminders 15 mins before classes start'),
          value: scheduleProvider.notificationsEnabled,
          activeColor: Colors.white,
          activeTrackColor: Colors.blue,
          onChanged: (value) {
            scheduleProvider.toggleNotifications(value);
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Custom Reminders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReminderFormPage()),
                  );
                },
              ),
            ],
          ),
        ),
        if (reminderProvider.reminders.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No custom reminders yet. Tap the + button to add one.'),
          )
        else
          ...reminderProvider.reminders.map((reminder) {
            final isPast = reminder.scheduledDate.isBefore(DateTime.now());
            return ListTile(
              leading: Checkbox(
                value: reminder.isCompleted,
                onChanged: (val) {
                  reminderProvider.toggleCompleted(reminder.id);
                },
              ),
              title: Text(
                reminder.title,
                style: TextStyle(
                  decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                  color: isPast && !reminder.isCompleted ? Colors.red : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (reminder.description.isNotEmpty) Text(reminder.description),
                  Text(
                    DateFormat.yMMMd().add_jm().format(reminder.scheduledDate),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReminderFormPage(reminderToEdit: reminder),
                    ),
                  );
                },
              ),
            );
          }).toList(),
      ],
    );
  }
}
