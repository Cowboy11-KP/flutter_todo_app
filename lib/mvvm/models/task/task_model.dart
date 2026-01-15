// lib/data/models/task_model.dart
import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 2) 
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? category;

  @HiveField(5)
  final int? priority;

  @HiveField(6)
  final bool isDone;

  @HiveField(7)
  final String? userId; // ID của user từ Firebase

  @HiveField(8)
  final bool isSynced; // Trạng thái đồng bộ

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.category,
    this.priority,
    this.isDone = false,
    this.userId, // Có thể null khi chưa login
    this.isSynced = false, // Mặc định là false khi mới tạo ở local
  });

  // Tạo bản sao với các giá trị mới (rất hữu ích khi cần update trạng thái synced)
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? category,
    int? priority,
    bool? isDone,
    String? userId,
    bool? isSynced,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'category': category,
        'priority': priority,
        'isDone': isDone,
        'userId': userId,
        // Không nhất thiết gửi isSynced lên Firestore, nhưng gửi cũng không sao
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'],
        date: DateTime.parse(json['date']),
        category: json['category'],
        priority: json['priority'],
        isDone: json['isDone'] ?? false,
        userId: json['userId'],
        isSynced: true, // Nếu tải từ Firebase về thì mặc định là true
      );
}