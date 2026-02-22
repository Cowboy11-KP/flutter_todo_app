import 'package:frontend/mvvm/models/user/user_model.dart';

enum UserStatus { initial, loading, success, error }

class UserState {
  final UserStatus status;
  final UserModel? user;
  final String? message;

  UserState({
    this.status = UserStatus.initial, 
    this.user, 
    this.message
  });

  UserState copyWith({UserStatus? status, UserModel? user, String? message}) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message ?? this.message,
    );
  }
}