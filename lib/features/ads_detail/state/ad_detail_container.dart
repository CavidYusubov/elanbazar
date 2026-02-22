import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ad_detail_repo.dart';
import '../models/ad_detail.dart';

final adDetailRepoProvider = Provider<AdDetailRepo>((ref) => AdDetailRepo());

final adDetailProvider =
    FutureProvider.family<AdDetail, int>((ref, adId) async {
  final map = await ref.read(adDetailRepoProvider).fetchAd(adId);
  return AdDetail.fromJson(map);
});