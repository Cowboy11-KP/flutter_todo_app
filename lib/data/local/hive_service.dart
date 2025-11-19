import 'package:frontend/data/models/category_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/data/models/task_model.dart';

class LocalTaskService {
  static const String boxName = 'Tasks';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskModelAdapter());
    await Hive.openBox<TaskModel>(boxName);
  }

  Box<TaskModel> get _box => Hive.box<TaskModel>(boxName);

  List<TaskModel> getTasks() => _box.values.toList();

  Future<void> addTask(TaskModel Task) async => await _box.put(Task.id, Task);

  Future<void> updateTask(TaskModel Task) async => await _box.put(Task.id, Task);

  Future<void> deleteTask(String id) async => await _box.delete(id);
}

class LocalCategoryService {
  final Box<CategoryModel> _box = Hive.box<CategoryModel>('categories');

  List<CategoryModel> getAll() => _box.values.toList();

  Future<void> add(CategoryModel category) async {
    await _box.put(category.label, category); // dùng label làm key
  }

  Future<void> delete(String label) async {
    await _box.delete(label);
  }

}
