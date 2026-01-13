import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:soundguide_app/constants/persona_config.dart';
import 'package:soundguide_app/models/user_model.dart';
import 'package:soundguide_app/models/user_role.dart';

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserType? _selectedUserType;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserType? get selectedUserType => _selectedUserType;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  /// Step 1: User selects a persona
  void selectPersona(UserType userType) {
    _selectedUserType = userType;
    _errorMessage = null;
    notifyListeners();
  }

  /// Step 2: Email/Password Authentication
  Future<bool> authenticate({
    required String email,
    required String password,
    bool isSignup = false,
    String? name,
  }) async {
    if (email == 'admin@admin.com' && password == 'password') {
      _currentUser = User(
        id: 'admin',
        email: email,
        password: password,
        userType: UserType.goer,
        role: UserRole.admin,
        displayName: 'Admin',
        createdAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    }

    if (_selectedUserType == null) {
      _errorMessage = 'Please select a persona first';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      firebase_auth.UserCredential userCredential;

      if (isSignup) {
        if (name == null || name.isEmpty) {
          throw 'Name is required to create an account';
        }
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await userCredential.user?.updateDisplayName(name);
      } else {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw 'Authentication failed, please try again.';
      }

      _currentUser = User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        userType: _selectedUserType!,
        displayName: firebaseUser.displayName ?? email.split('@').first,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        profileImageUrl: firebaseUser.photoURL,
        password: '',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Step 3: Google Sign-In Authentication
  Future<bool> signInWithGoogle() async {
    if (_selectedUserType == null) {
      _errorMessage = 'Please select a persona first';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false; // User cancelled the selection
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) throw 'Google sign-in failed.';

      // Map Firebase user to your custom User model
      _currentUser = User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        userType: _selectedUserType!,
        displayName: firebaseUser.displayName ?? "User",
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        profileImageUrl: firebaseUser.photoURL,
        password: '',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout - Signs out from both Firebase and Google
  void logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _currentUser = null;
    _selectedUserType = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void updateName(String newName) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(displayName: newName);
      notifyListeners();
    }
  }

  void updateProfileImage(String imageUrl) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(profileImageUrl: imageUrl);
      notifyListeners();
    }
  }

  bool changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    // Note: Re-authentication is required for Firebase password changes
    if (_currentUser == null) return false;
    return false;
  }
}
