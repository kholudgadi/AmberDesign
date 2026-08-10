import 'api_client.dart';
import 'auth_service.dart';

class OrdersService {
  OrdersService._();
  static final instance = OrdersService._();
  final _api = ApiClient();

  Future<List<Map<String, dynamic>>> list() async {
    final response = await _api.get('/orders', token: await AuthService.instance.accessToken());
    return (response['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> detail(String id) async {
    final response = await _api.get('/orders/$id', token: await AuthService.instance.accessToken());
    return response['data'] as Map<String, dynamic>;
  }
}
