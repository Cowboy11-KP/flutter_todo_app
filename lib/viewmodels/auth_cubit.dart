import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  // Logic Đăng nhập Email
  Future<void> loginEmail({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await _repository.signInWithEmail(email, password);
      if (user != null) emit(Authenticated(user.uid));
    } catch (e) {
      emit(AuthError("Sai email hoặc mật khẩu!"));
    }
  }

  // Logic Đăng nhập Google
  Future<void> loginGoogle() async {
    emit(AuthLoading());
    try {
      final user = await _repository.signInWithGoogle();
      if (user != null) {
        emit(Authenticated(user.uid));
      } else {
        emit(AuthInitial()); // Người dùng hủy đăng nhập
      }
    } catch (e) {
      emit(AuthError("Lỗi đăng nhập Google: ${e.toString()}"));
    }
  }

  Future<void> registerEmail({ required String userName,required String email, required String password}) async {
  emit(AuthLoading());
  try {
    // Giả sử AuthRepository của bạn đã có hàm signUpWithEmail
    final user = await _repository.signUpWithEmail(userName, email, password);
    if (user != null) {
      emit(Authenticated(user.uid));
    }
  } catch (e) {
    emit(AuthError("Đăng ký thất bại: ${e.toString()}"));
  }
}
}