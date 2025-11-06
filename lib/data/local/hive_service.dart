import 'package:frontend/data/models/category_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/data/models/todo_model.dart';

class LocalTodoService {
  static const String boxName = 'todos';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoModelAdapter());
    await Hive.openBox<TodoModel>(boxName);
  }

  Box<TodoModel> get _box => Hive.box<TodoModel>(boxName);

  List<TodoModel> getTodos() => _box.values.toList();

  Future<void> addTodo(TodoModel todo) async => await _box.put(todo.id, todo);

  Future<void> updateTodo(TodoModel todo) async => await _box.put(todo.id, todo);

  Future<void> deleteTodo(String id) async => await _box.delete(id);
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
