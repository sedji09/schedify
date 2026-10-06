import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule.dart';
import '../pages/schedule_form_page.dart';
import '../providers/schedule_provider.dart';
import 'package:provider/provider.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final DateTime? selectedDate;
  final bool isEditable;

  const ScheduleCard({
    Key? key, 
    required this.schedule, 
    this.selectedDate,
    this.isEditable = true,
  }) : super(key: key);

  String _formatTime(BuildContext context, TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: schedule.color, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isEditable ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleFormPage(scheduleToEdit: schedule),
            ),
          );
        } : null,
        onLongPress: selectedDate == null ? null : () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.event_busy, color: Colors.redAccent),
                      title: const Text('Cancel class for this date', style: TextStyle(color: Colors.redAccent)),
                      onTap: () {
                        Navigator.pop(context);
                        final provider = Provider.of<ScheduleProvider>(context, listen: false);
                        final updatedExcluded = List<DateTime>.from(schedule.excludedDates)..add(selectedDate!);
                        final updatedSchedule = Schedule(
                           id: schedule.id,
                           subject: schedule.subject,
                           professor: schedule.professor,
                           room: schedule.room,
                           day: schedule.day,
                           startTime: schedule.startTime,
                           endTime: schedule.endTime,
                           color: schedule.color,
                           notes: schedule.notes,
                           excludedDates: updatedExcluded,
                        );
                        provider.updateSchedule(updatedSchedule);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      schedule.subject,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: schedule.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      schedule.day.name.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: schedule.color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 4),
                  Text(schedule.professor),
                  const SizedBox(width: 16),
                  const Icon(Icons.room, size: 16),
                  const SizedBox(width: 4),
                  Text(schedule.room),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text('${_formatTime(context, schedule.startTime)} - ${_formatTime(context, schedule.endTime)}'),
                ],
              ),
              if (schedule.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  schedule.notes,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
