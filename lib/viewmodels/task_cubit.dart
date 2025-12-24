import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/task_model.dart';
import 'package:frontend/repository/task/task_repository.dart';
import 'package:frontend/service/notification_service.dart';
import 'package:frontend/viewmodels/task_state.dart';
import 'package:flutter/material.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;

  TaskCubit(this.repository) : super(TaskInitial());

  int _getNotificationId(String taskId) {
    return taskId.hashCode & 0x7FFFFFFF;
  }
  
  /// Load dữ liệu từ local + sync Firebase
  Future<void> loadTodos() async {
    emit(TaskLoading());
    try {
      final localTasks = repository.getLocalTasks();
      emit(TaskLoaded(localTasks));
    } catch (e) {
      emit(TaskError('Không thể tải dữ liệu: $e'));
    }
  }
  
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

      if (task.date.isAfter(DateTime.now())) {
          await NotificationService.scheduleNotification(
            id: _getNotificationId(task.id), // SỬA: Dùng hàm helper
            title: task.title,
            body: "Đến giờ: ${task.title}",
            scheduledTime: task.date,
            taskId: task.id, // SỬA: Thêm taskId để Action Button hoạt động
          );
        }

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
      
      await NotificationService.cancel(_getNotificationId(task.id));

      if (!task.isDone && task.date.isAfter(DateTime.now())) {
        await NotificationService.scheduleNotification(
          id: _getNotificationId(task.id),
          title: task.title,
          body: "Đến giờ: ${task.title}",
          scheduledTime: task.date,
          taskId: task.id, // SỬA: Thêm taskId
        );
      }
      
      final tasks = repository.getLocalTasks();
      debugPrint("✅Task update success");
      debugPrint("   🏷️  Title: ${task.title}");
      debugPrint("   📝  Description: ${task.description}");
      debugPrint("   📅  Date: ${task.date}");
      debugPrint("   📂  Category: ${task.category}");
      debugPrint("   ⭐  Priority: ${task.priority}");
      debugPrint("   🆔  ID: ${task.id}");
      debugPrint("   Tổng số task hiện tại: ${tasks.length}");

      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Không thể cập nhật: $e'));
    }
  }

  Future<void> markDoneFromNotification(String id) async {
    if (state is TaskLoaded) {
      final currentTasks = (state as TaskLoaded).tasks;
      final newTasks = currentTasks.map((t) {
        if (t.id == id) {
            return TaskModel(
            id: t.id,
            title: t.title,
            description: t.description,
            date: t.date,
            category: t.category,
            priority: t.priority,
            isDone: true,
          );
        }
        return t;
      }).toList();
      
      emit(TaskLoaded(newTasks));
    }

    await repository.updateIsDone(id);
    
  }

  /// delete Task
  Future<void> deleteTask(String id) async {
    try {
      await repository.deleteTask(id);

      await NotificationService.cancel(_getNotificationId(id));

      final tasks = repository.getLocalTasks();
      emit(TaskActionSuccess(tasks, 'Đã xóa task thành công!'));
    } catch (e) {
      emit(TaskError('Xóa thất bại: $e'));
    }
  }
}
