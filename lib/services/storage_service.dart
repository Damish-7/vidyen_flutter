import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _tokenKey = 'vidyen_jwt_token';
  static const String _userKey = 'vidyen_user_data';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return UserModel.fromJson(json, json['token'] ?? '');
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
