import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/todo_model.dart';
import 'package:frontend/repository/todo_repository.dart';
import 'package:frontend/viewmodels/todo_state.dart';
import 'package:flutter/material.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository repository;

  TodoCubit(this.repository) : super(TodoInitial());

  /// Load dữ liệu từ local + sync Firebase
  Future<void> loadTodos() async {
    emit(TodoLoading());
    try {
      final localTodos = repository.getLocalTodos();
      emit(TodoLoaded(localTodos));

      // await repository.syncFromFirebase();
      final updatedTodos = repository.getLocalTodos();
      emit(TodoLoaded(updatedTodos));
    } catch (e) {
      emit(TodoError('Không thể tải dữ liệu: $e'));
    }
  }

  /// Thêm Todo mới
  Future<void> addTodo({
  required String title,
  String description = '',
  DateTime? date,
  String? category,
  int? priority,
}) async {
  try {
    final todo = TodoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: date ?? DateTime.now(),
      category: category,
      priority: priority,
      isDone: false,
    );

    await repository.addTodo(todo);
    final todos = repository.getLocalTodos();

    // ✅ In ra log chi tiết
    debugPrint("✅ Đã thêm task mới:");
    debugPrint("   🏷️  Title: ${todo.title}");
    debugPrint("   📝  Description: ${todo.description}");
    debugPrint("   📅  Date: ${todo.date}");
    debugPrint("   📂  Category: ${todo.category}");
    debugPrint("   ⭐  Priority: ${todo.priority}");
    debugPrint("   🆔  ID: ${todo.id}");
    debugPrint("   Tổng số task hiện tại: ${todos.length}");

    emit(TodoActionSuccess(todos, 'Đã thêm task thành công!'));
  } catch (e) {
    debugPrint("❌ Lỗi khi thêm task: $e");
    emit(TodoError('Thêm thất bại: $e'));
  }
}


  /// Toggle done
  Future<void> toggleDone(TodoModel todo) async {
    try {
      final updated = TodoModel(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        date: todo.date,
        category: todo.category,
        priority: todo.priority,
        isDone: !todo.isDone,
      );

      await repository.updateTodo(updated);
      final todos = repository.getLocalTodos();
      emit(TodoLoaded(todos));
    } catch (e) {
      emit(TodoError('Không thể cập nhật: $e'));
    }
  }

  /// Xóa Todo
  Future<void> deleteTodo(String id) async {
    try {
      await repository.deleteTodo(id);
      final todos = repository.getLocalTodos();
      emit(TodoActionSuccess(todos, 'Đã xóa task thành công!'));
    } catch (e) {
      emit(TodoError('Xóa thất bại: $e'));
    }
  }
}
