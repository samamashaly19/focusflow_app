// lib/data/models/task_model.dart
class TaskModel {
  int? id;
  String title;
  String date; // YYYY-MM-DD
  String time; // HH:mm
  int isCompleted; // 0/1

  TaskModel({
    this.id,
    required this.title,
    required this.date,
    required this.time,
    this.isCompleted = 0,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
    id: map['id'] as int?,
    title: map['title'] as String,
    date: map['date'] as String,
    time: map['time'] as String,
    isCompleted: map['isCompleted'] as int,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'date': date,
    'time': time,
    'isCompleted': isCompleted,
  };
}
