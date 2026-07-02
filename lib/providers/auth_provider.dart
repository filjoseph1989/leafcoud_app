import 'package:flutter/material.dart';
import 'package:leaf_cloud/core/constants.dart';
import 'package:leaf_cloud/models/user_model.dart';
import 'package:leaf_cloud/repositories/auth_repository_interface.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepository;

  AuthProvider(this._authRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoginResponse? _loginResponse;
  LoginResponse? get loginResponse => _loginResponse;

  bool get isAdmin => _loginResponse?.user?.isAdmin ?? false;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _loginResponse = await _authRepository.login(email, password);
      ApiConstants.token = _loginResponse?.token;
      ApiConstants.refreshToken = _loginResponse?.refreshToken;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final accessToken = ApiConstants.token;
    final refreshToken = ApiConstants.refreshToken;

    // Clear local session state instantly
    _loginResponse = null;
    ApiConstants.token = null;
    ApiConstants.refreshToken = null;
    notifyListeners();

    // Invoke server logout in the background
    if (accessToken != null && refreshToken != null) {
      try {
        await _authRepository.logout(accessToken, refreshToken);
      } catch (e) {
        debugPrint('Server-side logout request failed: $e');
      }
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(name, email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.resetPassword(token, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    final accessToken = ApiConstants.token;
    if (accessToken == null) {
      _errorMessage = 'User is not logged in';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _authRepository.updateProfile(
        accessToken,
        name: name,
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      final shouldLogout = (email != null && email.trim() != _loginResponse?.user?.email) ||
                           (newPassword != null && newPassword.isNotEmpty);

      if (shouldLogout) {
        await logout();
      } else {
        if (_loginResponse != null) {
          _loginResponse = LoginResponse(
            status: _loginResponse!.status,
            token: _loginResponse!.token,
            refreshToken: _loginResponse!.refreshToken,
            message: _loginResponse!.message,
            user: updatedUser,
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

