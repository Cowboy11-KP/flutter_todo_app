import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/repository/task/task_repository.dart';
import 'package:frontend/repository/user/user_repository.dart';
import '../service/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  final TaskRepository _taskRepository;
  final UserRepository _userRepository;
  
  AuthRepository({
    required AuthService authService,
    required UserRepository userRepository,
    required TaskRepository taskRepository,
  })  : _authService = authService,
        _userRepository = userRepository,
        _taskRepository = taskRepository;

  Future<User?> signInWithEmail(String email, String password) async {
    final credential = await _authService.loginWithEmail(email, password);

    if (credential.user != null) {    
      await _taskRepository.syncLocalDataToFirebase(credential.user!.uid);
    }

    return credential.user;
  }

  Future<User?> signInWithGoogle() async {
    final credential = await _authService.loginWithGoogle();

    if (credential != null && credential.user != null) {
      // Gọi đồng bộ ngay sau khi login thành công
      await _taskRepository.syncLocalDataToFirebase(credential.user!.uid);
    }
    
    return credential?.user;
  }

  Future<User?> signUpWithEmail(String userName, String email, String password) async {
    final credential = await _authService.signUpWithEmail(userName, email, password);

    if (credential.user != null) {
      // Gọi sang UserRepository để lưu database
      final newUser = UserModel.fromFirebaseUser(credential.user!).copyWith(displayName: userName);
      await _userRepository.createUser(newUser);
      
      // Đồng bộ task
      await _taskRepository.syncLocalDataToFirebase(credential.user!.uid);
    }
    return credential.user;
  }

  Future<void> logOut() async {
    await _authService.logout();
  }
}