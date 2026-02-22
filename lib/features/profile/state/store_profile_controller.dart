import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/store_profile_repo.dart';
import '../../discover/data/models/ad_list_item.dart';

final storeProfileRepoProvider = Provider((ref) => StoreProfileRepo());

final storeProfileControllerProvider =
    StateNotifierProvider.family<StoreProfileController, StoreProfileState, String>((ref, slug) {
  return StoreProfileController(ref.read(storeProfileRepoProvider), slug);
});

class StoreProfileState {
  final bool loading;
  final bool loadingMore;
  final List<AdListItem> ads;
  final String? nextCursor;
  final bool hasMore;
  final Map<String, dynamic>? store;
  final Map<String, dynamic>? stats;
  final bool isFollowing;
  final String? error;
  final bool gridView;

  const StoreProfileState({
    required this.loading,
    required this.loadingMore,
    required this.ads,
    required this.nextCursor,
    required this.hasMore,
    this.store,
    this.stats,
    required this.isFollowing,
    this.error,
    required this.gridView,
  });

  factory StoreProfileState.initial() => const StoreProfileState(
        loading: true,
        loadingMore: false,
        ads: [],
        nextCursor: null,
        hasMore: true,
        store: null,
        stats: null,
        isFollowing: false,
        error: null,
        gridView: true,
      );

  StoreProfileState copyWith({
    bool? loading,
    bool? loadingMore,
    List<AdListItem>? ads,
    String? nextCursor,
    bool? hasMore,
    Map<String, dynamic>? store,
    Map<String, dynamic>? stats,
    bool? isFollowing,
    String? error,
    bool? gridView,
  }) {
    return StoreProfileState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      ads: ads ?? this.ads,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      store: store ?? this.store,
      stats: stats ?? this.stats,
      isFollowing: isFollowing ?? this.isFollowing,
      error: error ?? this.error,
      gridView: gridView ?? this.gridView,
    );
  }
}

class StoreProfileController extends StateNotifier<StoreProfileState> {
  StoreProfileController(this._repo, this.slug) : super(StoreProfileState.initial()) {
    loadInitial();
  }

  final StoreProfileRepo _repo;
  final String slug;
  bool _busy = false;

  Future<void> loadInitial() async {
    if (_busy) return;
    _busy = true;
    state = state.copyWith(loading: true, error: null);
    try {
      final r = await _repo.fetchProfile(slug: slug);
      state = state.copyWith(
        loading: false,
        ads: r.ads,
        nextCursor: r.nextCursor,
        hasMore: r.hasMore,
        store: r.store,
        stats: r.stats,
        isFollowing: r.isFollowing,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString(), hasMore: false);
    } finally {
      _busy = false;
    }
  }

  Future<void> loadMore() async {
    if (_busy) return;
    if (!state.hasMore) return;
    if (state.nextCursor == null || state.nextCursor!.isEmpty) return;

    _busy = true;
    state = state.copyWith(loadingMore: true);
    try {
      final r = await _repo.fetchProfile(slug: slug, cursor: state.nextCursor);
      state = state.copyWith(
        loadingMore: false,
        ads: [...state.ads, ...r.ads],
        nextCursor: r.nextCursor,
        hasMore: r.hasMore,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, error: e.toString());
    } finally {
      _busy = false;
    }
  }

  void toggleView() {
    state = state.copyWith(gridView: !state.gridView);
  }
}
