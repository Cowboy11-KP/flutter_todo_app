import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/task_model.dart';
import 'package:frontend/repository/task/task_repository.dart';
import 'package:frontend/service/notification_service.dart';
import 'package:frontend/viewmodels/task_state.dart';
import 'package:flutter/material.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;

  TaskCubit(this.repository) : super(TaskInitial());

  /// add task
  Future<void> addTask({
  required String title,
  String description = '',
  DateTime? date,
  String? category,
  int? priority,
}) async {
  try {
    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: date ?? DateTime.now(),
      category: category,
      priority: priority,
      isDone: false,
    );

    await repository.addTask(task);
    final tasks = repository.getLocalTasks();

    await NotificationService.scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: "Đến giờ: ${title}",
      scheduledTime: date ?? DateTime.now()
    );

    // ✅ In ra log chi tiết
    debugPrint("✅ Đã thêm task mới:");
    debugPrint("   🏷️  Title: ${task.title}");
    debugPrint("   📝  Description: ${task.description}");
    debugPrint("   📅  Date: ${task.date}");
    debugPrint("   📂  Category: ${task.category}");
    debugPrint("   ⭐  Priority: ${task.priority}");
    debugPrint("   🆔  ID: ${task.id}");
    debugPrint("   Tổng số task hiện tại: ${tasks.length}");

    emit(TaskActionSuccess(tasks, 'Đã thêm task thành công!'));
  } catch (e) {
    debugPrint("❌ Lỗi khi thêm task: $e");
    emit(TaskError('Thêm thất bại: $e'));
  }
}


  /// update task
  Future<void> updateTask(TaskModel task) async {
    try {
      final updated = TaskModel(
        id: task.id,
        title: task.title,
        description: task.description,
        date: task.date,
        category: task.category,
        priority: task.priority,
        isDone: task.isDone,
      );

      await repository.updateTask(updated);
      
      await NotificationService.cancel(task.id.hashCode);

      await NotificationService.scheduleNotification(
        id: task.id.hashCode,
        title: task.title,
        body: "Đến giờ: ${task.title}",
        scheduledTime: task.date,
      );

      final Tasks = repository.getLocalTasks();
      emit(TaskLoaded(Tasks));
    } catch (e) {
      emit(TaskError('Không thể cập nhật: $e'));
    }
  }

  /// delete Task
  Future<void> deleteTask(String id) async {
    try {
      await repository.deleteTask(id);
      final Tasks = repository.getLocalTasks();
      emit(TaskActionSuccess(Tasks, 'Đã xóa task thành công!'));
    } catch (e) {
      emit(TaskError('Xóa thất bại: $e'));
    }
  }
}
