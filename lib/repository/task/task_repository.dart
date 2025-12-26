import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/data/local/hive_service.dart'; 
import 'package:frontend/models/task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskRepository {
  final LocalTaskService local;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TaskRepository({required this.local});

  // --- HÀM TRỢ GIÚP: Đẩy dữ liệu lên Firestore ---
  Future<void> _uploadToFirestore(TaskModel task, String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.title)
        .set(task.toJson());
  }

  // 1. THÊM TASK
  Future<void> addTask(TaskModel task) async {
    await local.addTask(task);

    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final localTask = task.copyWith(isSynced: false);
      try {
        // Sau đó mới đẩy lên Firebase
        final syncedTask = localTask.copyWith(userId: currentUser.uid, isSynced: true);
        await _uploadToFirestore(syncedTask, currentUser.uid);
        
        // Nếu thành công, cập nhật lại trạng thái isSynced = true ở local
        await local.updateTask(syncedTask);
      } catch (e) {
        print("❌ Lỗi upload Firestore: $e - Task vẫn được lưu ở Local.");
      }
    }
  }

  // 2. CẬP NHẬT TRẠNG THÁI DONE
  Future<void> updateIsDone(String id) async {
    final tasks = local.getTasks();
    final task = tasks.firstWhere((e) => e.id == id);

    // BƯỚC 1: Cập nhật Local ngay lập tức (isSynced = false)
    final updatedTask = task.copyWith(isDone: !task.isDone, isSynced: false);
    await local.updateTask(updatedTask);
    
    // BƯỚC 2: Thử cập nhật lên Firebase nếu có login
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('tasks')
            .doc(id)
            .update({'isDone': updatedTask.isDone});
        
        // BƯỚC 3: Đánh dấu đã sync thành công
        await local.updateTask(updatedTask.copyWith(isSynced: true));
      } catch (e) {
        print("❌ Lỗi cập nhật Firebase, sẽ sync sau: $e");
      }
    }
  }

  // 3. CẬP NHẬT TOÀN BỘ TASK (Tên, ngày tháng...)
  Future<void> updateTask(TaskModel task) async {
    // Luôn ưu tiên Local
    final updatedLocal = task.copyWith(isSynced: false);
    await local.updateTask(updatedLocal);

    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _uploadToFirestore(updatedLocal.copyWith(isSynced: true), currentUser.uid);
        await local.updateTask(updatedLocal.copyWith(isSynced: true));
      } catch (e) {
        print("❌ Lỗi updateTask Firebase: $e");
      }
    }
  }

  // 4. XÓA TASK
  Future<void> deleteTask(String id) async {
    // Xóa Local trước
    await local.deleteTask(id);

    // Xóa Firebase sau
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('tasks')
            .doc(id)
            .delete();
      } catch (e) {
        print("❌ Lỗi xóa trên Firebase: $e");
      }
    }
  }

  // 5. LOGIC ĐỒNG BỘ (Dùng khi mạng ổn định lại hoặc khi login)
  Future<void> syncLocalDataToFirebase(String uid) async {
    final localTasks = local.getTasks();
    final unsyncedTasks = localTasks.where((task) => !task.isSynced).toList();

    if (unsyncedTasks.isEmpty) return;

    for (var task in unsyncedTasks) {
      try {
        final taskToSync = task.copyWith(userId: uid, isSynced: true);
        await _uploadToFirestore(taskToSync, uid);
        await local.updateTask(taskToSync);
      } catch (e) {
        print("❌ Lỗi đồng bộ task ${task.id}: $e");
      }
    }
  }

  // 6. LẤY DỮ LIỆU TỪ FIREBASE VỀ LOCAL
  Future<void> syncTasksFromFirebase(String uid) async {
    try {
      // Lấy snapshot từ Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .get();

      if (querySnapshot.docs.isEmpty) return;

      // Chuyển đổi dữ liệu từ Firestore thành danh sách TaskModel
      final List<TaskModel> firebaseTasks = querySnapshot.docs.map((doc) {
        return TaskModel.fromJson(doc.data());
      }).toList();

      // Lấy danh sách task hiện tại ở Local để so sánh
      final localTasks = local.getTasks();

      for (var fbTask in firebaseTasks) {
        // Kiểm tra xem task từ Firebase đã tồn tại ở Local chưa
        final existsLocally = localTasks.any((lt) => lt.id == fbTask.id);

        if (!existsLocally) {
          // Nếu chưa có ở Local -> Thêm mới vào Hive
          await local.addTask(fbTask.copyWith(isSynced: true));
        } else {
          // Nếu đã có -> Cập nhật Local theo Firebase (vì Firebase được coi là "nguồn sự thật" cuối cùng)
          // Bạn có thể thêm logic so sánh updatedAt nếu model có trường thời gian chỉnh sửa
          await local.updateTask(fbTask.copyWith(isSynced: true));
        }
      }
      print("✅ Đồng bộ từ Firebase về Local thành công.");
    } catch (e) {
      print("❌ Lỗi syncTasksFromFirebase: $e");
      rethrow; // Ném lỗi để Cubit có thể bắt và hiển thị thông báo
    }
  }

  List<TaskModel> getLocalTasks() => local.getTasks();
}