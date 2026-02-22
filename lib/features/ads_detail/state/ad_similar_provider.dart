import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ad_similar_repo.dart';

final adSimilarRepoProvider = Provider<AdSimilarRepo>((ref) => AdSimilarRepo());

final adSimilarProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, adId) async {
  return ref.read(adSimilarRepoProvider).fetchSimilar(adId, take: 12);
});