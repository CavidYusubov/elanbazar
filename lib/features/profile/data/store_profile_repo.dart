import 'package:elanbazar/features/discover/data/models/ad_list_item.dart';
import '../../../core/network/api_client.dart';

class StoreProfileResponse {
  final Map<String, dynamic> store;
  final Map<String, dynamic> stats;
  final bool isFollowing;
  final List<AdListItem> ads;
  final String? nextCursor;
  final bool hasMore;

  StoreProfileResponse({
    required this.store,
    required this.stats,
    required this.isFollowing,
    required this.ads,
    this.nextCursor,
    required this.hasMore,
  });
}

class StoreProfileRepo {
  Future<StoreProfileResponse> fetchProfile({
    required String slug,
    String? cursor,
    int perPage = 20,
  }) async {
    final qp = <String, dynamic>{
      'per_page': perPage,
    };
    if (cursor != null && cursor.isNotEmpty) qp['cursor'] = cursor;

    final res = await ApiClient.I.dio.get('/stores/$slug', queryParameters: qp);
    final body = res.data;

    if (body is Map && body['ok'] == true) {
      final data = body['data'];
      if (data is Map) {
        final Map<String, dynamic> store = (data['store'] is Map)
            ? Map<String, dynamic>.from(data['store'])
            : <String, dynamic>{};
        final Map<String, dynamic> stats = (data['stats'] is Map)
            ? Map<String, dynamic>.from(data['stats'])
            : <String, dynamic>{};
        final bool isFollowing = data['is_following'] == true;

        List itemsList = [];
        if (data['ads'] is Map && data['ads']['items'] is List) {
          itemsList = data['ads']['items'];
        }
        final ads = itemsList
            .whereType<Map>()
            .map((e) => AdListItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        String? nextCursor;
        bool hasMore = false;
        if (body['meta'] is Map) {
          final meta = body['meta'];
          nextCursor = meta['next_cursor']?.toString();
          if (meta['has_more'] is bool) hasMore = meta['has_more'] as bool;
        }

        return StoreProfileResponse(
          store: store,
          stats: stats,
          isFollowing: isFollowing,
          ads: ads,
          nextCursor: nextCursor,
          hasMore: hasMore,
        );
      }
    }

    throw Exception('Store profile request failed');
  }
}
