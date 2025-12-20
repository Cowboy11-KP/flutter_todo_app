import 'package:frontend/models/category_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/models/task_model.dart';

class LocalTaskService {
  static const String boxName = 'Tasks';

  Box<TaskModel> get _box => Hive.box<TaskModel>(boxName);

  List<TaskModel> getTasks() => _box.values.toList();

  Future<void> addTask(TaskModel task) async => _box.put(task.id, task);

  Future<void> updateTask(TaskModel task) async => _box.put(task.id, task);

  Future<void> deleteTask(String id) async => _box.delete(id);
}

class LocalCategoryService {
  Box<CategoryModel> get _box => Hive.box<CategoryModel>('categories');

  List<CategoryModel> getAll() => _box.values.toList();

  Future<void> add(CategoryModel category) async {
    await _box.put(category.label, category);
  }

  Future<void> delete(String label) async {
    await _box.delete(label);
  }
}

