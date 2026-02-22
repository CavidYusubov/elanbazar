import '../../../core/network/api_client.dart';
import 'models/ad_list_item.dart';

class DiscoverResponse {
  final List<AdListItem> items;
  final String? nextCursor;
  final bool hasMore;

  DiscoverResponse({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });
}

class DiscoverRepo {
  Future<DiscoverResponse> fetchAds({
    required String scope,
    String? cursor,
    int perPage = 20,
  }) async {
    final qp = <String, dynamic>{
      'scope': scope,
      'per_page': perPage,
    };
    if (cursor != null && cursor.isNotEmpty) qp['cursor'] = cursor;

    final res = await ApiClient.I.dio.get('/ads', queryParameters: qp);
    final body = res.data;

    if (body is Map && body['ok'] == true) {
      final data = body['data'];
      final meta = body['meta'];

      if (data is Map && data['items'] is List) {
        final list = (data['items'] as List)
            .whereType<Map>()
            .map((e) => AdListItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        final nextCursor = (meta is Map) ? meta['next_cursor']?.toString() : null;
        final hasMore = (meta is Map && meta['has_more'] is bool) ? meta['has_more'] as bool : false;

        return DiscoverResponse(items: list, nextCursor: nextCursor, hasMore: hasMore);
      }
    }

    throw Exception('Discover ads request failed');
  }
}