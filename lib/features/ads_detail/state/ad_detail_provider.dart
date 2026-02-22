import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ad_detail_repo.dart';
import '../models/ad_detail.dart';

final adDetailRepoProvider = Provider<AdDetailRepo>((ref) {
  return AdDetailRepo();
});

final adDetailProvider =
    FutureProvider.family<AdDetail, int>((ref, adId) async {
  return ref.read(adDetailRepoProvider).fetchAd(adId);
});