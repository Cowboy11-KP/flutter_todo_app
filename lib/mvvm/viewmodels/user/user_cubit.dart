import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;

  UserCubit(this._userRepository) : super(UserState(status: UserStatus.initial)) {
    fetchCurrentUser(); // Chạy ngay lập tức khi app mở
  }

  // Lấy data user
  Future<void> getProfile(String uid) async {
    emit(state.copyWith(status: UserStatus.loading));
    try {
      final user = await _userRepository.getUserData(uid);
      emit(state.copyWith(status: UserStatus.success, user: user));
    } catch (e) {
      emit(state.copyWith(status: UserStatus.error, message: e.toString()));
    }
  }

  // Cập nhật tên
  Future<void> updateName(String uid, String newName) async {
    emit(state.copyWith(status: UserStatus.loading));
    try {
      await _userRepository.updateDisplayName(uid, newName);
      // Cập nhật lại state cục bộ thay vì gọi lại API để tiết kiệm
      if (state.user != null) {
        final updatedUser = state.user!.copyWith(displayName: newName);
        emit(state.copyWith(status: UserStatus.success, user: updatedUser));
      }
    } catch (e) {
      emit(state.copyWith(status: UserStatus.error, message: e.toString()));
    }
  }

  // Đổi mật khẩu
  Future<void> changePassword(String newPassword) async {
    emit(state.copyWith(status: UserStatus.loading));
    try {
      await _userRepository.changePassword(newPassword);
      emit(state.copyWith(status: UserStatus.success, message: "Đổi mật khẩu thành công"));
    } catch (e) {
      emit(state.copyWith(status: UserStatus.error, message: e.toString()));
    }
  }

  Future<void> fetchCurrentUser() async {
    emit(state.copyWith(status: UserStatus.loading));
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      
      if (firebaseUser != null) {
        // Lấy data từ Firestore dựa trên UID của Firebase Auth
        final userData = await _userRepository.getUserData(firebaseUser.uid);
        if (userData != null) {
          emit(state.copyWith(status: UserStatus.success, user: userData));
        } else {
          // Firebase Auth có nhưng Firestore chưa có (hiếm gặp)
          emit(state.copyWith(status: UserStatus.success, user: null));
        }
      } else {
        // Không có user đăng nhập -> Guest
        emit(state.copyWith(status: UserStatus.success, user: null));
      }
    } catch (e) {
      emit(state.copyWith(status: UserStatus.error, message: e.toString()));
    }
  }
}