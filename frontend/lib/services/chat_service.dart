import 'api_client.dart';
import 'auth_service.dart';

class ChatService {
  ChatService._();
  static final instance = ChatService._();
  final _api = ApiClient();

  Future<List<Map<String, dynamic>>> conversations() async {
    final response = await _api.get('/chat/conversations', token: await AuthService.instance.accessToken());
    return (response['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
  }

  Future<String> openConversation({required String participantId, String? orderId, String? designRequestId}) async {
    final response = await _api.post('/chat/conversations', {
      'participantId': participantId,
      if (orderId != null) 'orderId': orderId,
      if (designRequestId != null) 'designRequestId': designRequestId,
    }, token: await AuthService.instance.accessToken());
    return (response['data'] as Map<String, dynamic>)['id'] as String;
  }

  Future<List<Map<String, dynamic>>> messages(String conversationId) async {
    final response = await _api.get('/chat/conversations/$conversationId/messages', token: await AuthService.instance.accessToken());
    return (response['data'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> send(String conversationId, String text) async {
    final response = await _api.post(
      '/chat/conversations/$conversationId/messages',
      {'text': text.trim()},
      token: await AuthService.instance.accessToken(),
    );
    return response['data'] as Map<String, dynamic>;
  }
}
