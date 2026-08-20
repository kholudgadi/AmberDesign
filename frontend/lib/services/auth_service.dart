import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();
  final _api = ApiClient();
  final _storage = const FlutterSecureStorage();
  static const _accessKey = 'amber_access_token';
  static const _refreshKey = 'amber_refresh_token';
  Future<String>? _refreshing;

  Future<String?> accessToken() async {
    final access = await _storage.read(key: _accessKey);
    if (access == null) return null;
    if (!_isExpired(access)) return access;
    return _refreshOnce();
  }

  bool _isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))) as Map<String, dynamic>;
      final expiresAt = (payload['exp'] as num?)?.toInt();
      if (expiresAt == null) return true;
      return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= expiresAt - 30;
    } catch (_) {
      return true;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required bool isDesigner,
  }) async {
    final response = await _api.post('/auth/register', {
      'email': email.trim().toLowerCase(), 'password': password,
      'displayName': displayName.trim(), 'phone': phone.trim(),
      'role': isDesigner ? 'designer' : 'customer', 'language': 'ar',
    });
    return _saveSession(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post('/auth/login', {'email': email.trim().toLowerCase(), 'password': password});
    return _saveSession(response);
  }

  Future<Map<String, dynamic>> currentUser() async {
    var access = await accessToken();
    if (access == null) throw const ApiException('يرجى تسجيل الدخول', 401, 'UNAUTHENTICATED');
    try {
      return (await _api.get('/auth/me', token: access))['data'] as Map<String, dynamic>;
    } on ApiException catch (error) {
      if (error.statusCode != 401) rethrow;
      access = await _refreshOnce();
      return (await _api.get('/auth/me', token: access))['data'] as Map<String, dynamic>;
    }
  }

  Future<T> authenticated<T>(Future<T> Function(String token) request) async {
    var token = await accessToken();
    if (token == null) throw const ApiException('يرجى تسجيل الدخول', 401, 'UNAUTHENTICATED');
    try {
      return await request(token);
    } on ApiException catch (error) {
      if (error.statusCode != 401) rethrow;
      token = await _refreshOnce();
      return request(token);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _api.post('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    }, token: await accessToken());
    await clearSession();
  }

  Future<String> _refresh() async {
    final refresh = await _storage.read(key: _refreshKey);
    if (refresh == null) throw const ApiException('انتهت الجلسة، سجل الدخول مجددًا', 401);
    final response = await _api.post('/auth/refresh', {'refreshToken': refresh});
    final data = response['data'] as Map<String, dynamic>;
    await _storage.write(key: _accessKey, value: data['accessToken'] as String);
    await _storage.write(key: _refreshKey, value: data['refreshToken'] as String);
    return data['accessToken'] as String;
  }

  Future<String> _refreshOnce() {
    final active = _refreshing;
    if (active != null) return active;
    final future = _refresh();
    _refreshing = future;
    return future.whenComplete(() => _refreshing = null);
  }

  Future<Map<String, dynamic>> _saveSession(Map<String, dynamic> response) async {
    final data = response['data'] as Map<String, dynamic>;
    await _storage.write(key: _accessKey, value: data['accessToken'] as String);
    await _storage.write(key: _refreshKey, value: data['refreshToken'] as String);
    return data['user'] as Map<String, dynamic>;
  }

  Future<void> clearSession() => _storage.deleteAll();
}
