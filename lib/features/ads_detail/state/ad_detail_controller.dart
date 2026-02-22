import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ad_detail_repo.dart';

final adDetailRepoProvider = Provider<AdDetailRepo>((ref) => AdDetailRepo());

final adDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, adId) async {
  return ref.read(adDetailRepoProvider).fetchAd(adId);
});