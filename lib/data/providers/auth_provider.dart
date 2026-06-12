import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final SessionService _sessionService;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _initialized = false;

  AuthProvider(this._apiService, this._sessionService);

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;

  Future<void> checkSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasSession = await _sessionService.hasSession();
      if (hasSession) {
        final data = await _sessionService.getSessionData();
        if (data['token'] != null && data['email'] != null && data['name'] != null) {
          _currentUser = UserModel(
            id: data['token']!,
            name: data['name']!,
            email: data['email']!,
            password: '',
          );
        }
      }
    } catch (e) {
      // Falla silenciosa
    } finally {
      _isLoading = false;
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newUser = UserModel(name: name, email: email, password: password);
      await _apiService.registerUser(newUser);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _apiService.loginUser(email, password);
      _currentUser = user;
      await _sessionService.saveSession(
        token: user.id ?? '',
        email: user.email,
        name: user.name,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _sessionService.clearSession();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
