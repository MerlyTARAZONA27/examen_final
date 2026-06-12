import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

class SessionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveSession({
    required String token,
    required String email,
    required String name,
  }) async {
    await _storage.write(key: AppConstants.keyUserToken, value: token);
    await _storage.write(key: AppConstants.keyUserEmail, value: email);
    await _storage.write(key: AppConstants.keyUserName, value: name);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: AppConstants.keyUserToken);
    await _storage.delete(key: AppConstants.keyUserEmail);
    await _storage.delete(key: AppConstants.keyUserName);
  }

  Future<bool> hasSession() async {
    final token = await _storage.read(key: AppConstants.keyUserToken);
    return token != null;
  }

  Future<Map<String, String?>> getSessionData() async {
    final token = await _storage.read(key: AppConstants.keyUserToken);
    final email = await _storage.read(key: AppConstants.keyUserEmail);
    final name = await _storage.read(key: AppConstants.keyUserName);
    return {'token': token, 'email': email, 'name': name};
  }
}
