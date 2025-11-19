import 'package:frontend/data/local/hive_service.dart';
import 'package:frontend/data/models/task_model.dart';

class TaskRepository {
  final LocalTaskService local;

  TaskRepository({required this.local});

  Future<void> addTask(TaskModel Task) async {
    await local.addTask(Task);
  }

  List<TaskModel> getLocalTasks() => local.getTasks();

  Future<void> updateTask(TaskModel Task) async {
    await local.updateTask(Task);
  }

  Future<void> deleteTask(String id) async {
    await local.deleteTask(id);
  }

}
