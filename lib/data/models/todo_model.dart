// lib/data/local/models/todo_model.dart
import 'package:hive/hive.dart';
part 'todo_model.g.dart';

@HiveType(typeId: 2) // chọn typeId khác với UserModel
class TodoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isDone;

  @HiveField(3)
  final DateTime createdAt;

  TodoModel({
    required this.id,
    required this.title,
    this.isDone = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // CHUYỂN SANG MAP để lưu lên Firestore
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isDone': isDone,
        'createdAt': createdAt.toIso8601String(),
      };

  // TẠO từ Map đọc từ Firestore
  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        isDone: json['isDone'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}
