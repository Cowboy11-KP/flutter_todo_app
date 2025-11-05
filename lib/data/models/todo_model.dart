// lib/data/local/models/todo_model.dart
import 'package:hive/hive.dart';
part 'todo_model.g.dart';

@HiveType(typeId: 2) // chọn typeId khác với UserModel
@HiveType(typeId: 2)
class TodoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date; // ngày (ngày, giờ)

  @HiveField(4)
  final String? category; // ví dụ: "University", "Work", "Personal"

  @HiveField(5)
  final int? priority; // 1, 2, 3,...

  @HiveField(6)
  final bool isDone;

  TodoModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.category ,
    this.priority,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'category': category,
    'priority': priority,
    'isDone': isDone,
  };

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    date: DateTime.parse(json['date']),
    category: json['category'],
    priority: json['priority'],
    isDone: json['isDone'] ?? false,
  );
}

