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
    List<String> referenceUrls = const [],
    String? details,
  }) async {
    final response = await _api.post('/orders/design-requests', {
      'category': category,
      'title': title,
      'specifications': specifications,
      'serviceFee': serviceFee,
      'platformFee': platformFee,
      'referenceUrls': referenceUrls,
      if (details != null && details.isNotEmpty) 'details': details,
    }, token: await AuthService.instance.accessToken());
    return response['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> availableDesignRequests() async {
    final response = await _api.get('/orders/design-requests-available', token: await AuthService.instance.accessToken());
    return (response['data'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> claimDesignRequest(String id) async {
    final response = await _api.post('/orders/design-requests/$id/claim', const {}, token: await AuthService.instance.accessToken());
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendOffer(String id, {
    required double price,
    String? duration,
    String? deliveryDate,
    String? message,
  }) async {
    final response = await _api.post('/orders/design-requests/$id/quote', {
      'price': price,
      if (duration != null && duration.isNotEmpty) 'duration': duration,
      if (deliveryDate != null && deliveryDate.isNotEmpty) 'deliveryDate': deliveryDate,
      if (message != null && message.isNotEmpty) 'message': message,
    }, token: await AuthService.instance.accessToken());
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> acceptOffer(String id) async {
    final response = await _api.post(
      '/orders/design-requests/$id/accept-quote',
      const {},
      token: await AuthService.instance.accessToken(),
    );
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> rejectOffer(String id) async {
    final response = await _api.post(
      '/orders/design-requests/$id/reject-quote',
      const {},
      token: await AuthService.instance.accessToken(),
    );
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateDesignRequestStatus(String id, String status) async {
    final response = await _api.patch(
      '/orders/design-requests/$id/status',
      {'status': status},
      token: await AuthService.instance.accessToken(),
    );
    return response['data'] as Map<String, dynamic>;
  }
}
