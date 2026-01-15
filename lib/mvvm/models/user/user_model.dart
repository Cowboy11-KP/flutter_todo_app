import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart'; // Tự sinh code adapter bằng build_runner

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String? email;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final String? photoUrl;

  @HiveField(4)
  final DateTime? createdAt;

  @HiveField(5) 
  final String? authMethod; 

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.authMethod, 
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    String? authMethod,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      authMethod: authMethod ?? this.authMethod,
    );
  }

  // Chuyển sang Map để lưu Firebase
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'createdAt': createdAt?.toIso8601String(),
        'authMethod': authMethod, 
      };

  // Parse ngược lại từ Firebase
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'] ?? '',
        email: map['email'],
        displayName: map['displayName'],
        photoUrl: map['photoUrl'],
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'])
            : null,
        authMethod: map['authMethod'] ?? 'password',
      );

  // Tạo từ Firebase User 
  factory UserModel.fromFirebaseUser(User user) {
    // Lấy danh sách provider
    final providers = user.providerData.map((e) => e.providerId).toList();
    
    // Logic xác định phương thức: Ưu tiên Google nếu có trong list
    String method = 'password';
    if (providers.contains('google.com')) {
      method = 'google.com';
    } else if (providers.contains('phone')) {
      method = 'phone';
    }

    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      authMethod: method,
    );
  }
}