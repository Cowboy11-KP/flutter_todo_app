import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/mvvm/models/user/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Lưu user mới (Gọi khi đăng ký thành công)
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  // 2. Lấy thông tin user hiện tại
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // 3. Cập nhật tên hiển thị
  Future<void> updateDisplayName(String uid, String newName) async {
    await _firestore.collection('users').doc(uid).update({
      'displayName': newName,
    });
  }

  // 4. Cập nhật ảnh đại diện
  Future<void> updatePhotoUrl(String uid, String newUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'photoUrl': newUrl,
    });
  }

  // Update password
  Future<void> changePassword(String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        print("✅ Cập nhật mật khẩu thành công");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print("❌ Lỗi: Người dùng cần đăng nhập lại trước khi đổi mật khẩu (vì lý do bảo mật)");
      }
    }
  }

  Future<void> updateAuthMethod(String uid, String newMethod) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'authMethod': newMethod,
      });
      print("✅ Đã cập nhật phương thức đăng nhập mới: $newMethod");
    } catch (e) {
      print("❌ Lỗi khi cập nhật authMethod: $e");
      rethrow;
    }
  }
}