import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();
  final _api = ApiClient();
  final _storage = const FlutterSecureStorage();
  static const _accessKey = 'amber_access_token';
  static const _refreshKey = 'amber_refresh_token';

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
    var access = await _storage.read(key: _accessKey);
    if (access == null) throw const ApiException('يرجى تسجيل الدخول', 401, 'UNAUTHENTICATED');
    try {
      return (await _api.get('/auth/me', token: access))['data'] as Map<String, dynamic>;
    } on ApiException catch (error) {
      if (error.statusCode != 401) rethrow;
      access = await _refresh();
      return (await _api.get('/auth/me', token: access))['data'] as Map<String, dynamic>;
    }
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

  Future<Map<String, dynamic>> _saveSession(Map<String, dynamic> response) async {
    final data = response['data'] as Map<String, dynamic>;
    await _storage.write(key: _accessKey, value: data['accessToken'] as String);
    await _storage.write(key: _refreshKey, value: data['refreshToken'] as String);
    return data['user'] as Map<String, dynamic>;
  }

  Future<void> clearSession() => _storage.deleteAll();
}
