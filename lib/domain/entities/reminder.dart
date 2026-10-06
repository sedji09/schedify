class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.title,
    this.description = '',
    required this.scheduledDate,
    this.isCompleted = false,
  });
}
