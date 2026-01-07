import 'package:flutter/material.dart';
import 'package:soundguide_app/constants/persona_config.dart';
import 'package:soundguide_app/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
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

  /// Step 1: User selects a persona
  void selectPersona(UserType userType) {
    _selectedUserType = userType;
    _errorMessage = null;
    notifyListeners();
  }

  /// Step 3: Mock login/signup
  Future<bool> authenticate({
    required String email,
    required String password,
    bool isSignup = false,
  }) async {
    if (_selectedUserType == null) {
      _errorMessage = 'Please select a persona first';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        throw 'Email and password are required';
      }

      if (!email.contains('@')) {
        throw 'Invalid email format';
      }

      if (password.length < 6) {
        throw 'Password must be at least 6 characters';
      }

      // Mock user creation
      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        password: password,
        userType: _selectedUserType!,
        displayName: email.split('@').first,
        createdAt: DateTime.now(),
      );

      // Step 4: Simulate backend request with userType + credentials
      await _simulateBackendAuth();

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

  /// Step 4: Simulate sending user data to backend
  Future<void> _simulateBackendAuth() async {
    if (_currentUser == null) return;

    // In production, this would be an actual HTTP request
    final backendPayload = {
      'action': 'authenticate',
      'credentials': {
        'email': _currentUser!.email,
        'password': _currentUser!.password,
      },
      'user_metadata': _currentUser!.toBackendJson(),
    };

    // Simulate backend processing
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real app, you'd handle the response and errors here
    debugPrint('Backend Auth Payload: $backendPayload');
  }

  void logout() {
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
