import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/schedule_provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/schedule_card.dart';
import '../../domain/entities/schedule.dart';
import 'reminder_form_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScheduleProvider>(context, listen: false).fetchSchedules();
    });
  }

  DayOfWeek _getCurrentDay() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case DateTime.monday: return DayOfWeek.monday;
      case DateTime.tuesday: return DayOfWeek.tuesday;
      case DateTime.wednesday: return DayOfWeek.wednesday;
      case DateTime.thursday: return DayOfWeek.thursday;
      case DateTime.friday: return DayOfWeek.friday;
      case DateTime.saturday: return DayOfWeek.saturday;
      case DateTime.sunday: return DayOfWeek.sunday;
      default: return DayOfWeek.monday;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScheduleProvider, ReminderProvider>(
      builder: (context, scheduleProvider, reminderProvider, child) {
        if (scheduleProvider.isLoading && scheduleProvider.schedules.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final todaySchedules = scheduleProvider.schedules.where((s) => s.day == _getCurrentDay()).toList();
        
        todaySchedules.sort((a, b) {
          if (a.startTime.hour != b.startTime.hour) {
            return a.startTime.hour.compareTo(b.startTime.hour);
          }
          return a.startTime.minute.compareTo(b.startTime.minute);
        });

        final now = DateTime.now();
        final todayReminders = reminderProvider.reminders.where((r) => isSameDay(r.scheduledDate, now)).toList();
        todayReminders.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

        return ListView(
          padding: const EdgeInsets.only(bottom: 80.0), // padding for FAB
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                "Today's Classes",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (todaySchedules.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No classes today! 🎉', style: TextStyle(fontSize: 16)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todaySchedules.length,
                itemBuilder: (context, index) {
                  return ScheduleCard(
                    schedule: todaySchedules[index],
                    isEditable: false,
                  );
                },
              ),
              
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Divider(),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Text(
                "Today's Reminders",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (todayReminders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No reminders for today.', style: TextStyle(fontSize: 16)),
              )
            else
              ...todayReminders.map((reminder) {
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
                        DateFormat.jm().format(reminder.scheduledDate),
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
              }),
          ],
        );
      },
    );
  }
}
