import 'package:frontend/data/local/hive_service.dart';
import 'package:frontend/data/models/todo_model.dart';

class TodoRepository {
  final LocalTodoService local;

  TodoRepository({required this.local});

  Future<void> addTodo(TodoModel todo) async {
    await local.addTodo(todo);
  }

  List<TodoModel> getLocalTodos() => local.getTodos();

  Future<void> updateTodo(TodoModel todo) async {
    await local.updateTodo(todo);
  }

  Future<void> deleteTodo(String id) async {
    await local.deleteTodo(id);
  }

}
