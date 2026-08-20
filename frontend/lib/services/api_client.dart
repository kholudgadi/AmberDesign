import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final String? code;
  final int statusCode;
  const ApiException(this.message, this.statusCode, [this.code]);
  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client;
  ApiClient([http.Client? client]) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {String? token}) =>
      _send('POST', path, body: body, token: token);

  Future<Map<String, dynamic>> get(String path, {String? token}) =>
      _send('GET', path, token: token);

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body, {String? token}) =>
      _send('PATCH', path, body: body, token: token);

  Future<Map<String, dynamic>> delete(String path, {Map<String, dynamic>? body, String? token}) =>
      _send('DELETE', path, body: body, token: token);

  Future<Map<String, dynamic>> _send(String method, String path, {Map<String, dynamic>? body, String? token}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    try {
      final headers = <String, String>{'Accept': 'application/json', 'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';
      final response = await _client.send(http.Request(method, uri)
        ..headers.addAll(headers)
        ..body = body == null ? '' : jsonEncode(body)).timeout(const Duration(seconds: 20));
      final text = await response.stream.bytesToString();
      final decoded = text.isEmpty ? <String, dynamic>{} : jsonDecode(text) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = decoded['error'] as Map<String, dynamic>?;
        throw ApiException(error?['message']?.toString() ?? 'تعذر إكمال الطلب', response.statusCode, error?['code']?.toString());
      }
      return decoded;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('تعذر الاتصال بالخادم. تأكد من تشغيله واتصال الشبكة.', 0, 'NETWORK_ERROR');
    }
  }
}
