import 'api_client.dart';
import 'auth_service.dart';

class DesignerService {
  DesignerService._();
  static final instance = DesignerService._();
  final _api = ApiClient();

  Future<String?> _token() => AuthService.instance.accessToken();

  Future<Map<String, dynamic>> dashboard() async {
    final response = await _api.get('/designers/me/dashboard', token: await _token());
    return response['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> myItems() async {
    final response = await _api.get('/catalog/me/items', token: await _token());
    return (response['data'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> categories() async {
    final response = await _api.get('/catalog/categories');
    return (response['data'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
  }

  Future<void> createItem(Map<String, dynamic> input) async {
    await _api.post('/catalog/items', input, token: await _token());
  }

  Future<Map<String, dynamic>> updateAccount({String? displayName, required String city, required String bio}) async {
    final response = await _api.patch('/users/me', {if (displayName != null) 'displayName': displayName, 'city': city, 'bio': bio}, token: await _token());
    return response['data'] as Map<String, dynamic>;
  }

  Future<void> updateProfessionalProfile({required int experienceYears, required List<String> specialties}) async {
    await _api.patch('/designers/me/profile', {'experienceYears': experienceYears, 'specialties': specialties}, token: await _token());
  }
}
