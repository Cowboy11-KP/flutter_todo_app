import 'package:frontend/data/local/hive_service.dart';
import 'package:frontend/data/models/todo_model.dart';
import 'package:frontend/viewmodels/auth_service.dart';
import 'package:frontend/data/remote/firebase_service.dart';

class TodoRepository {
  final LocalTodoService local;
  final FirebaseTodoService remote;
  final AuthService authService;

  TodoRepository({
    required this.local,
    required this.remote,
    required this.authService,
  });

  /// 🔹 Thêm Todo cả local + Firebase (nếu có user)
  Future<void> addTodo(TodoModel todo) async {
    await local.addTodo(todo);
    if (authService.currentUser != null) {
      await remote.addTodoForUser(authService.currentUser!.uid, todo);
    }
  }

  /// 🔹 Đồng bộ từ Firebase về Hive
  Future<void> syncFromFirebase() async {
    if (authService.currentUser == null) return;
    final todos = await remote.getTodosForUser(authService.currentUser!.uid);
    for (var todo in todos) {
      await local.addTodo(todo);
    }
  }

  /// 🔹 Lấy todo từ local
  List<TodoModel> getLocalTodos() => local.getTodos();

  /// 🔹 Cập nhật todo
  Future<void> updateTodo(TodoModel todo) async {
    await local.updateTodo(todo);
    if (authService.currentUser != null) {
      await remote.updateTodoForUser(authService.currentUser!.uid, todo);
    }
  }

  /// 🔹 Xóa todo
  Future<void> deleteTodo(String id) async {
    await local.deleteTodo(id);
    if (authService.currentUser != null) {
      await remote.deleteTodoForUser(authService.currentUser!.uid, id);
    }
  }
}
