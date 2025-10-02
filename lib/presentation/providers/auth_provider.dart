import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    final user = _authService.currentUser;
    if (user != null) {
      await loadCurrentUser();
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('AuthProvider: Loading current user...');
      _currentUser = await _authService.getCurrentUserProfile();
      
      if (_currentUser != null) {
        debugPrint('AuthProvider: User loaded successfully - ${_currentUser!.email}');
      } else {
        debugPrint('AuthProvider: No user profile found');
      }
      
      _error = null;
    } catch (e) {
      debugPrint('AuthProvider: Error loading user - $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String accountType,
    String? firstName,
    String? lastName,
    String? displayName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signUpWithEmail(
        email: email,
        password: password,
        accountType: accountType,
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
      );

      // Wait a bit more and retry loading user if needed
      await Future.delayed(const Duration(milliseconds: 500));
      await loadCurrentUser();
      
      // Retry if user is still null
      if (_currentUser == null) {
        await Future.delayed(const Duration(milliseconds: 1000));
        await loadCurrentUser();
      }
      
      return _currentUser != null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithEmail(email: email, password: password);
      await loadCurrentUser();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithGoogle();
      await loadCurrentUser();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _userRepository.updateUserProfile(_currentUser!.id, updates);
      await loadCurrentUser();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
