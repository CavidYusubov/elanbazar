import '../../../core/network/api_client.dart';

class AdSimilarRepo {
  Future<List<Map<String, dynamic>>> fetchSimilar(int adId, {int take = 12}) async {
    final res = await ApiClient.I.dio.get('/ads/$adId/similar', queryParameters: {'take': take});
    final body = res.data;

    if (body is Map && body['ok'] == true) {
      final data = body['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return <Map<String, dynamic>>[];
    }

    throw Exception('Similar ads failed');
  }
}