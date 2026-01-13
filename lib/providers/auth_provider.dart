import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:soundguide_app/constants/persona_config.dart';
import 'package:soundguide_app/models/user_model.dart';
import 'package:soundguide_app/models/user_role.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
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

  /// Step 2: Email/Password Authentication (Signup & Login)
  Future<bool> authenticate({
    required String email,
    required String password,
    bool isSignup = false,
    String? name,
  }) async {
    // Admin bypass logic
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
        if (name == null || name.isEmpty)
          throw 'Name is required to create an account';

        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Create the local model
        _currentUser = User(
          id: userCredential.user!.uid,
          email: email,
          password: '',
          userType: _selectedUserType!,
          displayName: name,
          createdAt: DateTime.now(),
          role: UserRole.user,
        );

        // SAVE TO FIRESTORE
        await _db
            .collection('users')
            .doc(_currentUser!.id)
            .set(_currentUser!.toMap());
      } else {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // FETCH FROM FIRESTORE
        final doc = await _db
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (doc.exists) {
          _currentUser = User.fromMap(doc.data()!);
          // Update selected persona to match the database truth
          _selectedUserType = _currentUser!.userType;
        } else {
          _currentUser = User.fromFirebaseUser(
            userCredential.user!,
            _selectedUserType ?? UserType.goer,
          );
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      final email = user?.email;

      if (user != null && email != null) {
        // 1. Create a credential for re-authentication
        firebase_auth.AuthCredential credential =
            firebase_auth.EmailAuthProvider.credential(
              email: email,
              password: currentPassword,
            );

        // 2. Re-authenticate the user
        await user.reauthenticateWithCredential(credential);

        // 3. Update the password
        await user.updatePassword(newPassword);

        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = _handleAuthError(e);
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

  /// Step 3: Google Sign-In
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) throw 'Google sign-in failed.';

      // Check if user already exists in Firestore
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists) {
        _currentUser = User.fromMap(doc.data()!);
        _selectedUserType = _currentUser!.userType;
      } else {
        // First time Google User: Create the document
        _currentUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          userType: _selectedUserType!,
          displayName: firebaseUser.displayName ?? "User",
          createdAt: DateTime.now(),
          profileImageUrl: firebaseUser.photoURL,
          password: '',
        );
        await _db
            .collection('users')
            .doc(_currentUser!.id)
            .set(_currentUser!.toMap());
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfileImage(String localPath) async {
    if (_currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      File file = File(localPath);

      // 1. Create a reference to Firebase Storage
      // Path: /profile_pics/USER_ID.jpg
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pics')
          .child('${_currentUser!.id}.jpg');

      // 2. Upload the file
      await storageRef.putFile(file);

      // 3. Get the public Download URL
      final String downloadUrl = await storageRef.getDownloadURL();

      // 4. Update Firestore document
      await _db.collection('users').doc(_currentUser!.id).update({
        'profileImageUrl': downloadUrl,
      });

      // 5. Update local state
      _currentUser = _currentUser!.copyWith(profileImageUrl: downloadUrl);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to upload image: $e";
      notifyListeners();
      rethrow;
    }
  }

  /// Update Display Name
  Future<void> updateName(String newName) async {
    if (_currentUser != null) {
      try {
        // 1. Update the cloud
        await _db.collection('users').doc(_currentUser!.id).update({
          'displayName': newName,
        });

        // 2. Update the local memory (This triggers the Drawer to change!)
        _currentUser = _currentUser!.copyWith(displayName: newName);

        // 3. Tell the UI to refresh
        notifyListeners();
      } catch (e) {
        debugPrint("Error updating name: $e");
      }
    }
  }

  /// Corrected Error Handler
  String _handleAuthError(dynamic e) {
    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid email or password. Please check your details.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        default:
          return e.message ?? 'Authentication failed.';
      }
    }
    return e.toString();
  }

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
}
