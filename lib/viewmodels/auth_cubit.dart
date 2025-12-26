import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/viewmodels/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthState.initial());

  // Đăng nhập Email
  Future<void> loginEmail({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loginEmailLoading));
    try {
      final user = await _repository.signInWithEmail(email, password);
      if (user != null) {
        emit(state.copyWith(status: AuthStatus.authenticated, uid: user.uid));
      } else {
        emit(state.copyWith(status: AuthStatus.initial));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, message: "Sai email hoặc mật khẩu!"));
      emit(state.copyWith(status: AuthStatus.initial, message: null)); // Reset trạng thái
    }
  }

  // Đăng nhập Google
  Future<void> loginGoogle() async {
    emit(state.copyWith(status: AuthStatus.loginGoogleLoading));
    try {
      final user = await _repository.signInWithGoogle();
      if (user != null) {
        emit(state.copyWith(status: AuthStatus.authenticated, uid: user.uid));
      } else {
        emit(state.copyWith(status: AuthStatus.initial));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, message: "Lỗi Google: ${e.toString()}"));
      emit(state.copyWith(status: AuthStatus.initial, message: null));
    }
  }

  // Đăng ký
  Future<void> registerEmail({required String userName, required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.registerLoading));
    try {
      final user = await _repository.signUpWithEmail(userName, email, password);
      if (user != null) {
        emit(state.copyWith(status: AuthStatus.authenticated, uid: user.uid));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, message: e.toString()));
      emit(state.copyWith(status: AuthStatus.initial, message: null));
    }
  }

  // Đăng xuất
  Future<void> logOut() async {
    emit(state.copyWith(status: AuthStatus.logoutLoading));
    try {
      await _repository.logOut();
      emit(AuthState.initial());
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, message: "Lỗi đăng xuất"));
      emit(state.copyWith(status: AuthStatus.initial, message: null));
    }
  }
}