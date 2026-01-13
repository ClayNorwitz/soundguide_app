import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:soundguide_app/constants/persona_config.dart';

class User {
  final String id;
  final String email;
  final String password; // In production, never store plain passwords
  final UserType userType;
  final String? displayName;
  final String? profileImageUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.userType,
    this.displayName,
    this.profileImageUrl,
    required this.createdAt,
  });

  factory User.fromFirebaseUser(
      firebase_auth.User firebaseUser, UserType userType) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      userType: userType,
      displayName: firebaseUser.displayName,
      profileImageUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      password: '',
    );
  }

  factory User.empty() {
    return User(
      id: '',
      email: '',
      password: '',
      userType: UserType.goer,
      createdAt: DateTime.now(),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? password,
    UserType? userType,
    String? displayName,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Mock backend serialization
  Map<String, dynamic> toBackendJson() {
    return {
      'email': email,
      'user_type': PersonaConfig.getBackendValue(userType),
      'display_name': displayName ?? email.split('@').first,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
