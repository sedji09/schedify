import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/schedule_card.dart';
import '../../domain/entities/schedule.dart';

class WeeklySchedulePage extends StatelessWidget {
  const WeeklySchedulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.schedules.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final schedulesByDay = <DayOfWeek, List<Schedule>>{};
        for (var day in DayOfWeek.values) {
          schedulesByDay[day] = provider.schedules.where((s) => s.day == day).toList();
          schedulesByDay[day]!.sort((a, b) {
            if (a.startTime.hour != b.startTime.hour) {
              return a.startTime.hour.compareTo(b.startTime.hour);
            }
            return a.startTime.minute.compareTo(b.startTime.minute);
          });
        }

        return ListView.builder(
          itemCount: DayOfWeek.values.length,
          itemBuilder: (context, index) {
            final day = DayOfWeek.values[index];
            final dailySchedules = schedulesByDay[day]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    day.name.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                if (dailySchedules.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('No classes'),
                  )
                else
                  ...dailySchedules.map((schedule) => ScheduleCard(schedule: schedule)).toList(),
                const Divider(),
              ],
            );
          },
        );
      },
    );
  }
}
