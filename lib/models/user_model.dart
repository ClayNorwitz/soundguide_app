import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:soundguide_app/constants/persona_config.dart';
import 'package:soundguide_app/models/user_role.dart';

class User {
  final String id;
  final String email;
  final String
  password; // Note: Only used during transport, never stored in Firestore
  final UserType userType;
  final String? displayName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final UserRole role;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.userType,
    this.displayName,
    this.profileImageUrl,
    required this.createdAt,
    this.role = UserRole.user,
  });

  // --- FIRESTORE SERIALIZATION ---

  /// Converts the User object into a Map to stay organized in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      // Uses your PersonaConfig to convert Enum to String (e.g., 'host' or 'goer')
      'userType': PersonaConfig.getBackendValue(userType),
      'displayName': displayName ?? email.split('@').first,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      // Converts UserRole enum to String (e.g., 'user' or 'admin')
      'role': role.toString().split('.').last,
    };
  }

  /// Creates a User object from a Firestore document
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      password: '', // Always empty when coming from DB for security
      userType: PersonaConfig.fromBackendValue(map['userType'] ?? 'goer'),
      displayName: map['displayName'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      role: UserRole.values.firstWhere(
        (r) => r.toString().split('.').last == (map['role'] ?? 'user'),
        orElse: () => UserRole.user,
      ),
    );
  }

  // --- HELPER CONSTRUCTORS ---

  /// Initial conversion when a user first signs up via Firebase Auth
  factory User.fromFirebaseUser(
    firebase_auth.User firebaseUser,
    UserType userType,
  ) {
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

  /// Empty state for initialization in Providers
  factory User.empty() {
    return User(
      id: '',
      email: '',
      password: '',
      userType: UserType.goer,
      createdAt: DateTime.now(),
    );
  }

  // --- UTILS ---

  User copyWith({
    String? id,
    String? email,
    String? password,
    UserType? userType,
    String? displayName,
    String? profileImageUrl,
    DateTime? createdAt,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }

  /// Backward compatibility for your existing mock backend logic
  Map<String, dynamic> toBackendJson() => toMap();
}
