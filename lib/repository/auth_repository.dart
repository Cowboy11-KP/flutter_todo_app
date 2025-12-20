import 'package:firebase_auth/firebase_auth.dart';
import '../service/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  AuthRepository(this._authService);

  Future<User?> signInWithEmail(String email, String password) async {
    final credential = await _authService.loginWithEmail(email, password);
    return credential.user;
  }

  Future<User?> signUpWithEmail(String userName, String email, String password) async {
    final credential = await _authService.signUpWithEmail(userName, email, password);
    return credential.user;
  }
  
  Future<User?> signInWithGoogle() async {
    final credential = await _authService.loginWithGoogle();
    return credential?.user;
  }
}