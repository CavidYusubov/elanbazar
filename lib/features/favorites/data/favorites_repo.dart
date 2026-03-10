import '../../../core/network/api_client.dart';
import '../../discover/data/models/ad_list_item.dart';

class FavoritesRepo {
  Future<List<AdListItem>> fetchByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final res = await ApiClient.I.dio.get(
      '/ads',
      queryParameters: {
        'ids': ids.join(','),
        'per_page': ids.length,
      },
    );

    final body = res.data;

    if (body is Map && body['ok'] == true) {
      final data = body['data'];
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map>()
            .map((e) => AdListItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    throw Exception('Favorites fetch failed');
  }
}