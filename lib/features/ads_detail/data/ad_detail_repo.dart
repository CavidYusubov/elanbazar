import '../../../core/network/api_client.dart';

class AdDetailRepo {
  Future<Map<String, dynamic>> fetchAd(int id) async {
    final res = await ApiClient.I.dio.get('/ads/$id');
    final body = res.data;

    if (body is Map && body['ok'] == true) {
      final data = body['data'];
      if (data is Map) return Map<String, dynamic>.from(data);
    }
    throw Exception('Ad detail failed');
  }
}