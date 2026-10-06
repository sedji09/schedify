import 'package:flutter/material.dart';

enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class Schedule {
  final String id;
  final String subject;
  final String professor;
  final String room;
  final DayOfWeek day;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color color;
  final String notes;
  final List<DateTime> excludedDates;

  Schedule({
    required this.id,
    required this.subject,
    required this.professor,
    required this.room,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.notes = '',
    this.excludedDates = const [],
  });
}
