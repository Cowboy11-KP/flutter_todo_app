import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/viewmodels/auth_service.dart';
import 'package:frontend/viewmodels/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;

  AuthCubit(this.authService) : super(AuthInitial());

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    final user = await authService.signInWithGoogle();
    if (user != null) {
      emit(AuthSuccess(user));
      print('Đăng nhập thành công, User ID: ${user.uid}');
    } else {
      emit(const AuthFailure("Đăng nhập thất bại"));
    }
  }

  Future<void> logout() async {
    await authService.signOut();
    emit(AuthInitial());
  }
}
