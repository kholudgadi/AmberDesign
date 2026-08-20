import 'api_client.dart';
import 'auth_service.dart';

class DesignerService {
  DesignerService._();
  static final instance = DesignerService._();
  final _api = ApiClient();

  Future<T> _authorized<T>(Future<T> Function(String token) request) => AuthService.instance.authenticated(request);

  Future<Map<String, dynamic>> dashboard() async =>
      (await _authorized((token) => _api.get('/designers/me/dashboard', token: token)))['data'] as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> products() async =>
      ((await _authorized((token) => _api.get('/catalog/me/items', token: token)))['data'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  Future<List<Map<String, dynamic>>> categories() async =>
      ((await _api.get('/catalog/categories'))['data'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  Future<String> createProduct(Map<String, dynamic> input) async =>
      ((await _authorized((token) => _api.post('/catalog/items', input, token: token)))['data'] as Map<String, dynamic>)['id'] as String;

  Future<void> updateProduct(String id, Map<String, dynamic> input) async {
    await _authorized((token) => _api.patch('/catalog/items/$id', input, token: token));
  }

  Future<void> deleteProduct(String id) async {
    await _authorized((token) => _api.delete('/catalog/items/$id', token: token));
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> input) async =>
      (await _authorized((token) => _api.patch('/users/me', input, token: token)))['data'] as Map<String, dynamic>;

  Future<void> updateDesignerProfile(Map<String, dynamic> input) async {
    await _authorized((token) => _api.patch('/designers/me/profile', input, token: token));
  }

  Future<List<Map<String, dynamic>>> reviews(String designerId) async =>
      ((await _api.get('/designers/$designerId/reviews'))['data'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  Future<List<Map<String, dynamic>>> portfolio(String designerId) async =>
      ((await _api.get('/designers/$designerId/portfolio'))['data'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  Future<Map<String, dynamic>> createPortfolio(Map<String, dynamic> input) async =>
      (await _authorized((token) => _api.post('/designers/me/portfolio', input, token: token)))['data'] as Map<String, dynamic>;

  Future<void> deletePortfolio(String id) async {
    await _authorized((token) => _api.delete('/designers/me/portfolio/$id', token: token));
  }

  Future<List<Map<String, dynamic>>> notifications() async =>
      ((await _authorized((token) => _api.get('/notifications', token: token)))['data'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  Future<void> markNotificationRead(String id) async {
    await _authorized((token) => _api.post('/notifications/$id/read', const {}, token: token));
  }

  Future<void> createSupportTicket({required String subject, required String message}) async {
    await _authorized((token) => _api.post('/support/tickets', {'subject': subject, 'category': 'other', 'message': message}, token: token));
  }
}
