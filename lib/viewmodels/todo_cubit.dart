import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/todo_model.dart';
import 'package:frontend/repository/todo_repository.dart';

class TodoCubit extends Cubit<List<TodoModel>> {
  final TodoRepository repository;

  TodoCubit(this.repository) : super([]);

  /// 🔹 Load dữ liệu từ local + sync với Firebase
  Future<void> loadTodos() async {
    // B1: Lấy dữ liệu local
    final localTodos = repository.getLocalTodos();
    emit(localTodos);

    // B2: Nếu có user, đồng bộ Firebase -> Hive
    await repository.syncFromFirebase();

    // B3: Lấy lại danh sách mới sau khi sync
    final updatedTodos = repository.getLocalTodos();
    emit(updatedTodos);
  }

  /// 🔹 Thêm Todo mới
  Future<void> addTodo(String title) async {
    final todo = TodoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    await repository.addTodo(todo);
    emit(repository.getLocalTodos());
  }

  /// 🔹 Đánh dấu hoàn thành / chưa hoàn thành
  Future<void> toggleDone(TodoModel todo) async {
    final updated = TodoModel(
      id: todo.id,
      title: todo.title,
      isDone: !todo.isDone,
      createdAt: todo.createdAt,
    );

    await repository.updateTodo(updated);
    emit(repository.getLocalTodos());
  }

  /// 🔹 Xóa Todo
  Future<void> deleteTodo(String id) async {
    await repository.deleteTodo(id);
    emit(repository.getLocalTodos());
  }
}
