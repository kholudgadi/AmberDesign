import 'api_client.dart';
import 'auth_service.dart';

class OrdersService {
  OrdersService._();
  static final instance = OrdersService._();
  final _api = ApiClient();

  Future<List<Map<String, dynamic>>> list() async {
    final token = await AuthService.instance.accessToken();
    final responses = await Future.wait([
      _api.get('/orders', token: token),
      _api.get('/orders/design-requests', token: token),
    ]);
    final regular = (responses[0]['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((order) => {...order, 'kind': 'order'});
    final requests = (responses[1]['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final all = [...regular, ...requests];
    all.sort((a, b) => (b['createdAt']?.toString() ?? '').compareTo(a['createdAt']?.toString() ?? ''));
    return all;
  }

  Future<Map<String, dynamic>> detail(String id, {String kind = 'order'}) async {
    final path = kind == 'design_request' ? '/orders/design-requests/$id' : '/orders/$id';
    final response = await _api.get(path, token: await AuthService.instance.accessToken());
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createDesignRequest({
    required String category,
    required String title,
    required Map<String, String> specifications,
    required double serviceFee,
    required double platformFee,
  }) async {
    final response = await _api.post('/orders/design-requests', {
      'category': category,
      'title': title,
      'specifications': specifications,
      'serviceFee': serviceFee,
      'platformFee': platformFee,
    }, token: await AuthService.instance.accessToken());
    return response['data'] as Map<String, dynamic>;
  }
}
