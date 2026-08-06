import 'package:flutter/foundation.dart';

class ApiConfig {
  static const _definedUrl = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_definedUrl.isNotEmpty) return _definedUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }
}
