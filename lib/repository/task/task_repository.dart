import 'package:frontend/data/local/hive_service.dart';
import 'package:frontend/models/task_model.dart';

class TaskRepository {
  final LocalTaskService local;

  TaskRepository({required this.local});

  Future<void> addTask(TaskModel task) async {
    await local.addTask(task);
  }

  List<TaskModel> getLocalTasks() => local.getTasks();

  Future<void> updateTask(TaskModel task) async {
    await local.updateTask(task);
  }

  Future<void> deleteTask(String id) async {
    await local.deleteTask(id);
  }

  Future<void> updateIsDone(String id) async {
    final tasks = local.getTasks();
    final task = tasks.firstWhere((e) => e.id == id);

    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      date: task.date,
      category: task.category,
      priority: task.priority,
      isDone: true, 
    );

    await local.updateTask(updatedTask);
  }
}
