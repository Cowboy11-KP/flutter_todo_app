import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/data/remote/auth_service.dart';
import 'package:hive/hive.dart';

class AuthRepository {
  final AuthService _service;
  final Box _box; // Hive box để lưu user/token

  AuthRepository(this._service, this._box);

  User? get currentUser => _service.currentUser;

  Stream<User?> get userChanges => _service.userChanges;

  Future<void> signInWithGoogle() async {
    final user = await _service.signInWithGoogle();
    if (user != null) {
      _box.put('user', user.uid); // lưu local bằng Hive
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    _box.delete('user');
  }
}
