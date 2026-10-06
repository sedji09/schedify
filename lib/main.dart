import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/models/schedule_model.dart';
import 'data/models/holiday_model.dart';
import 'data/models/reminder_model.dart';
import 'data/datasources/hive_schedule_data_source.dart';
import 'data/repositories/schedule_repository_impl.dart';
import 'data/repositories/holiday_repository_impl.dart';
import 'domain/usecases/add_schedule.dart';
import 'domain/usecases/delete_schedule.dart';
import 'domain/usecases/get_schedules.dart';
import 'domain/usecases/search_schedules.dart';
import 'domain/usecases/update_schedule.dart';
import 'presentation/pages/main_navigation_page.dart';
import 'presentation/providers/schedule_provider.dart';
import 'presentation/providers/reminder_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleModelAdapter());
  Hive.registerAdapter(HolidayModelAdapter());
  Hive.registerAdapter(ReminderModelAdapter());

  final scheduleBox = await Hive.openBox<ScheduleModel>('schedules');
  final holidayBox = await Hive.openBox<HolidayModel>('holidays');
  final reminderBox = await Hive.openBox<ReminderModel>('reminders');

  // Initialize notifications
  final notificationService = LocalNotificationService();
  await notificationService.init();

  // Dependency Injection (simple manual setup for Clean Architecture)
  final dataSource = HiveScheduleDataSourceImpl(scheduleBox);
  final repository = ScheduleRepositoryImpl(dataSource);
  final holidayRepository = HolidayRepositoryImpl(holidayBox);

  final getSchedules = GetSchedules(repository);
  final addSchedule = AddSchedule(repository);
  final updateSchedule = UpdateSchedule(repository);
  final deleteSchedule = DeleteSchedule(repository);
  final searchSchedules = SearchSchedules(repository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider(
            getSchedulesUseCase: getSchedules,
            addScheduleUseCase: addSchedule,
            updateScheduleUseCase: updateSchedule,
            deleteScheduleUseCase: deleteSchedule,
            searchSchedulesUseCase: searchSchedules,
            holidayRepository: holidayRepository,
            notificationService: notificationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(
            reminderBox: reminderBox,
            notificationService: notificationService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const StudentScheduleApp(),
    ),
  );
}

class StudentScheduleApp extends StatelessWidget {
  const StudentScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Schedify',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}
