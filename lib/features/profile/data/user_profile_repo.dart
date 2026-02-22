import 'package:elanbazar/features/discover/data/models/ad_list_item.dart';
import '../../../core/network/api_client.dart';

class UserProfileResponse {
  final Map<String, dynamic> user;
  final Map<String, dynamic> stats;
  final List<AdListItem> ads;
  final String? nextCursor;
  final bool hasMore;

  UserProfileResponse({
    required this.user,
    required this.stats,
    required this.ads,
    this.nextCursor,
    required this.hasMore,
  });
}

class UserProfileRepo {
  Future<UserProfileResponse> fetchProfile({
    required int userId,
    String? cursor,
    int perPage = 20,
  }) async {
    final qp = <String, dynamic>{
      'per_page': perPage,
    };
    if (cursor != null && cursor.isNotEmpty) qp['cursor'] = cursor;

    final res = await ApiClient.I.dio.get('/users/$userId', queryParameters: qp);
    final body = res.data;

    if (body is Map && body['ok'] == true) {
      final data = body['data'];
      if (data is Map) {
        final Map<String, dynamic> user = (data['user'] is Map) ? Map<String, dynamic>.from(data['user']) : <String, dynamic>{};
        final Map<String, dynamic> stats = (data['stats'] is Map) ? Map<String, dynamic>.from(data['stats']) : <String, dynamic>{};
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

        return UserProfileResponse(
          user: user,
          stats: stats,
          ads: ads,
          nextCursor: nextCursor,
          hasMore: hasMore,
        );
      }
    }

    throw Exception('User profile request failed');
  }
}
