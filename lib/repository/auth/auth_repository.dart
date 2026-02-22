import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/datasources/local/hive_service.dart';
import 'package:frontend/mvvm/models/user/user_model.dart';
import 'package:frontend/repository/task/task_repository.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/service/firebase_auth_service.dart';


class AuthRepository {
  final AuthService _authService;
  final LocalTaskService _local;
  final TaskRepository _taskRepository;
  final UserRepository _userRepository;
  
  AuthRepository({
    required AuthService authService,
    required LocalTaskService local,
    required UserRepository userRepository,
    required TaskRepository taskRepository,
  })  : _authService = authService,
        _local = local,
        _userRepository = userRepository,
        _taskRepository = taskRepository;

  Future<User?> signInWithEmail(String email, String password) async {
    final credential = await _authService.loginWithEmail(email, password);

    if (credential.user != null) {    
      await Future.wait([
        _taskRepository.syncLocalDataToFirebase(credential.user!.uid),
        _taskRepository.syncTasksFromFirebase(credential.user!.uid),
      ]);
    }

    return credential.user;
  }

  Future<User?> signInWithGoogle() async {
    final credential = await _authService.loginWithGoogle();

    if (credential != null && credential.user != null) {
      final userDoc = await _userRepository.getUserData(credential.user!.uid);
  
      if (userDoc == null) {
        // User hoàn toàn mới
        final newUser = UserModel.fromFirebaseUser(credential.user!).copyWith(authMethod: 'google.com');
        await _userRepository.createUser(newUser);
      } else {

        if (userDoc.authMethod != 'google.com') {
          await _userRepository.updateAuthMethod(credential.user!.uid, 'google.com');
        }
      }

       await Future.wait([
        _taskRepository.syncLocalDataToFirebase(credential.user!.uid),
        _taskRepository.syncTasksFromFirebase(credential.user!.uid),
      ]);
    }
    
    return credential?.user;
  }

  Future<User?> signUpWithEmail(String userName, String email, String password) async {
    final credential = await _authService.signUpWithEmail(userName, email, password);

    if (credential.user != null) {
      final newUser = UserModel.fromFirebaseUser(credential.user!).copyWith(
        displayName: userName,
        authMethod: 'password',
      );
      await _userRepository.createUser(newUser);
      await _taskRepository.syncLocalDataToFirebase(credential.user!.uid);
    }
    return credential.user;
  }

  Future<void> logOut() async {
    // await _local.clearAllTasks();
    await _authService.logout();
  }
}