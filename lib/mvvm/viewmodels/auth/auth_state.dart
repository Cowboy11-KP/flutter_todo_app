enum AuthStatus { 
  initial, 
  loginEmailLoading,    
  loginGoogleLoading,   
  registerLoading, 
  logoutLoading, 
  authenticated, 
  error 
}

class AuthState {
  final AuthStatus status;
  final String? uid;
  final String? message;

  AuthState({
    required this.status,
    this.uid,
    this.message,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    String? uid,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      uid: uid ?? this.uid,
      message: message ?? this.message, // Lưu ý: giữ message cũ nếu không truyền mới
    );
  }
}