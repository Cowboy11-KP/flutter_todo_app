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
      emit(TaskLoaded(_sortTasks(localTasks)));
    } catch (e) {
      emit(TaskError('Không thể tải dữ liệu: $e'));
    }
  }
  
  // --- HÀM SẮP XẾP DÙNG CHUNG ---
  List<TaskModel> _sortTasks(List<TaskModel> tasks) {
    return tasks..sort((a, b) {
      // 1. Sắp xếp theo ngày giờ tăng dần
      int dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;

      // 2. Nếu cùng giờ, ưu tiên Priority cao hơn lên trước (ví dụ 1 là cao nhất)
      // Nếu priority là null thì cho xuống cuối (mặc định là 10)
      return (a.priority ?? 10).compareTo(b.priority ?? 10);
    });
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

      emit(TaskActionSuccess(_sortTasks(tasks), 'Đã thêm task thành công!'));
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

  // ================= DATA ANALYTICS (CLEANED) =================

  /// 1. Lọc dữ liệu cho Bar Chart (Week/Month/Year)
  Map<int, int> getTaskAnalytics(String filterType) {
    final tasks = repository.getLocalTasks();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Map<int, int> data = {};

    if (filterType == 'Week') {
      data = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
      // Thứ 2 tuần này
      DateTime startOfWeek = today.subtract(Duration(days: now.weekday - 1));
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));

      for (var t in tasks) {
        DateTime taskDay = DateTime(t.date.year, t.date.month, t.date.day);
        if ((taskDay.isAtSameMomentAs(startOfWeek) || taskDay.isAfter(startOfWeek)) && taskDay.isBefore(endOfWeek)) {
          data[t.date.weekday] = (data[t.date.weekday] ?? 0) + 1;
        }
      }
    } 
    else if (filterType == 'Month') {
      for (int i = 1; i <= 31; i++) data[i] = 0;
      for (var t in tasks) {
        if (t.date.month == now.month && t.date.year == now.year) {
          data[t.date.day] = (data[t.date.day] ?? 0) + 1;
        }
      }
    } 
    else if (filterType == 'Year') {
      for (int i = 1; i <= 12; i++) data[i] = 0;
      for (var t in tasks) {
        if (t.date.year == now.year) {
          data[t.date.month] = (data[t.date.month] ?? 0) + 1;
        }
      }
    }
    return data;
  }

  /// 2. Thống kê theo Category cho Pie Chart
  Map<String, int> getTaskCountByCategory() {
    Map<String, int> data = {};
    final tasks = repository.getLocalTasks();
    
    for (var task in tasks) {
      String cat = task.category ?? "Other";
      data[cat] = (data[cat] ?? 0) + 1;
    }
    return data;
  }
}
