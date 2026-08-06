import 'api_client.dart';

class CatalogService {
  CatalogService._();
  static final instance = CatalogService._();
  final _api = ApiClient();

  Future<({List<dynamic> categories, List<dynamic> items})> loadHome({String query = '', String? categoryId}) async {
    final parameters = <String, String>{'limit': '12'};
    if (query.trim().isNotEmpty) parameters['q'] = query.trim();
    if (categoryId != null) parameters['categoryId'] = categoryId;
    final itemsPath = Uri(path: '/catalog/items', queryParameters: parameters).toString();
    final results = await Future.wait([
      _api.get('/catalog/categories'),
      _api.get(itemsPath),
    ]);
    return (
      categories: results[0]['data'] as List<dynamic>? ?? const [],
      items: results[1]['data'] as List<dynamic>? ?? const [],
    );
  }
}
