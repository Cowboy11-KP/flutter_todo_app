import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Khởi tạo GoogleSignIn với scopes rõ ràng
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Đăng nhập với Google
  Future<User?> signInWithGoogle() async {
    try {
      // Chọn tài khoản Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Người dùng hủy

      // Lấy authentication
      final googleAuth = await googleUser.authentication;

      // Tạo credential Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e, stack) {
      print('Sign in failed: $e');
      print(stack);
      return null;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  /// Stream thay đổi user
  Stream<User?> get userChanges => _auth.userChanges();
}
