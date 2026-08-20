import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'api_client.dart';
import 'auth_service.dart';

class UploadException implements Exception {
  final String message;
  const UploadException(this.message);
  @override
  String toString() => message;
}

class UploadService {
  UploadService._();
  static final instance = UploadService._();
  final _api = ApiClient();
  final _http = http.Client();

  static const _contentTypes = {
    'jpg': 'image/jpeg', 'jpeg': 'image/jpeg',
    'png': 'image/png', 'webp': 'image/webp',
  };

  Future<String> uploadImage(XFile file) async {
    final extension = file.name.split('.').last.toLowerCase();
    final contentType = _contentTypes[extension];
    if (contentType == null) {
      throw const UploadException('صيغة الصورة غير مدعومة (استخدم jpg أو png أو webp)');
    }
    final token = await AuthService.instance.accessToken();
    final signed = await _api.post('/platform/uploads/sign', {
      'contentType': contentType,
      'extension': extension,
    }, token: token);
    final data = signed['data'] as Map<String, dynamic>;
    final response = await _http.put(
      Uri.parse(data['uploadUrl'] as String),
      headers: {'Content-Type': contentType},
      body: await file.readAsBytes(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const UploadException('فشل رفع الصورة، حاول مرة أخرى');
    }
    final confirmed = await _api.post('/platform/uploads/confirm', {
      'path': data['path'] as String,
    }, token: token);
    return (confirmed['data'] as Map<String, dynamic>)['url'] as String;
  }

  Future<List<String>> uploadImages(List<XFile> files) async {
    final urls = <String>[];
    for (final file in files) {
      urls.add(await uploadImage(file));
    }
    return urls;
  }
}
