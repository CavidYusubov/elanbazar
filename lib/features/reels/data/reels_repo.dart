import '../../../core/network/api_client.dart';
import 'models/reel_ad.dart';

class ReelsResponse {
  final List<ReelAd> items;
  final bool hasMore;
  ReelsResponse({required this.items, required this.hasMore});
}

class ReelsRepo {
  Future<ReelsResponse> fetchReels({List<int> exclude = const []}) async {
    final q = <String, dynamic>{};
    if (exclude.isNotEmpty) q['exclude'] = exclude.join(',');

    final res = await ApiClient.I.dio.get('/reels', queryParameters: q);
    final body = res.data;

    if (body is Map && body['ok'] == true) {
      final data = body['data'];
      final meta = body['meta'];

      bool hasMore = false;
      if (meta is Map && meta['has_more'] is bool) {
        hasMore = meta['has_more'] as bool;
      }

      List itemsList = const [];
      // data = { items: [...] }
      if (data is Map && data['items'] is List) itemsList = data['items'];
      // data birbaşa list olsa
      if (data is List) itemsList = data;

      final items = itemsList
          .whereType<Map>()
          .map((e) => ReelAd.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return ReelsResponse(items: items, hasMore: hasMore);
    }

    final msg = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Reels request failed';
    throw Exception(msg);
  }
}