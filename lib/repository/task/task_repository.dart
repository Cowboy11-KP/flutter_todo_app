import 'package:frontend/data/local/hive_service.dart';
import 'package:frontend/data/models/task_model.dart';

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

}
