class Task {
  String title;
  String description;
  String category;
  String priority;
  DateTime dueDate;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });
}