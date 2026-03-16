import '../config/api_config.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  /// Login with username + password
  /// Returns UserModel on success, throws on failure
  Future<UserModel> login(String username, String password) async {
    final res = await _api.post(
      ApiConfig.login,
      {'username': username, 'password': password},
      auth: false,
    );

    if (res['status'] != true) {
      throw Exception(res['message'] ?? 'Login failed');
    }

    final data = res['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data, token);

    await _storage.saveToken(token);
    await _storage.saveUser(user);

    return user;
  }

  /// Change password (first login)
  Future<void> changePassword(String newPassword) async {
    final res = await _api.post(
      ApiConfig.changePassword,
      {'new_password': newPassword},
    );
    if (res['status'] != true) {
      throw Exception(res['message'] ?? 'Change password failed');
    }
  }

  /// Fetch current user info
  Future<UserModel?> getCurrentUser() async {
    return await _storage.getUser();
  }

  /// Restore session from storage
  Future<UserModel?> restoreSession() async {
    return await _storage.getUser();
  }

  /// Logout - clear storage
  Future<void> logout() async {
    await _storage.clear();
  }
}
