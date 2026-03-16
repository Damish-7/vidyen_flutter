import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';

/// Low-level HTTP helper with automatic Bearer token injection
class ApiService {
  final StorageService _storage = StorageService();

  // ── Generic request helpers ──────────────────────────────────────────────

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _storage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String url) async {
    final res = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      print('📤 POST $url');
      print('📦 Body: $body');
      final res = await http.post(
        Uri.parse(url),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      print('📥 Response: ${res.statusCode} - ${res.body}');
      return _decode(res);
    } catch (e) {
      print('❌ API Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    final res = await http.put(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    try {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return json;
    } catch (_) {
      return {
        'status': false,
        'message': 'Invalid server response (${res.statusCode})',
        'data': null
      };
    }
  }
}
