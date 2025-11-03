import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/data/models/todo_model.dart';

class FirebaseTodoService {
  final _firestore = FirebaseFirestore.instance;

  /// 🟢 Thêm 1 todo cho user
  Future<void> addTodoForUser(String uid, TodoModel todo) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('todos')
        .doc(todo.id) // id có thể là uuid
        .set(todo.toJson());
  }

  /// 🟢 Lấy danh sách todo cho user
  Future<List<TodoModel>> getTodosForUser(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('todos')
        .get();

    return snapshot.docs
        .map((doc) => TodoModel.fromJson(doc.data()))
        .toList();
  }

  /// (Tùy chọn) Xóa todo
  Future<void> deleteTodoForUser(String uid, String todoId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('todos')
        .doc(todoId)
        .delete();
  }

  /// (Tùy chọn) Cập nhật todo
  Future<void> updateTodoForUser(String uid, TodoModel todo) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('todos')
        .doc(todo.id)
        .update(todo.toJson());
  }
}
