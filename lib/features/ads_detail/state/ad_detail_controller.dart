import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ad_detail_repo.dart';

final adDetailRepoProvider = Provider<AdDetailRepo>((ref) => AdDetailRepo());

