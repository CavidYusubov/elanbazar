import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../discover/data/models/ad_list_item.dart';
import '../data/favorites_local_store.dart';
import '../data/favorites_repo.dart';

final favoritesLocalStoreProvider = Provider<FavoritesLocalStore>((ref) {
  return FavoritesLocalStore();
});

final favoritesRepoProvider = Provider<FavoritesRepo>((ref) {
  return FavoritesRepo();
});

final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, FavoritesState>((ref) {
  return FavoritesController(
    ref.read(favoritesLocalStoreProvider),
    ref.read(favoritesRepoProvider),
  );
});

final favoriteIdsProvider = Provider<Set<int>>((ref) {
  return ref.watch(favoritesControllerProvider).ids.toSet();
});

final isFavoriteProvider = Provider.family<bool, int>((ref, adId) {
  final ids = ref.watch(favoriteIdsProvider);
  return ids.contains(adId);
});

class FavoritesState {
  final bool loading;
  final bool syncing;
  final List<int> ids;
  final List<AdListItem> items;
  final String? error;

  const FavoritesState({
    required this.loading,
    required this.syncing,
    required this.ids,
    required this.items,
    required this.error,
  });

  factory FavoritesState.initial() {
    return const FavoritesState(
      loading: true,
      syncing: false,
      ids: [],
      items: [],
      error: null,
    );
  }

  FavoritesState copyWith({
    bool? loading,
    bool? syncing,
    List<int>? ids,
    List<AdListItem>? items,
    String? error,
    bool clearError = false,
  }) {
    return FavoritesState(
      loading: loading ?? this.loading,
      syncing: syncing ?? this.syncing,
      ids: ids ?? this.ids,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class FavoritesController extends StateNotifier<FavoritesState> {
  FavoritesController(this._localStore, this._repo) : super(FavoritesState.initial()) {
    load();
  }

  final FavoritesLocalStore _localStore;
  final FavoritesRepo _repo;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final ids = await _localStore.getIds();
      final items = await _repo.fetchByIds(ids);

      state = state.copyWith(
        loading: false,
        ids: ids,
        items: items,
        clearError: true,
      );
    } catch (e) {
      final ids = await _localStore.getIds();
      state = state.copyWith(
        loading: false,
        ids: ids,
        items: const [],
        error: e.toString(),
      );
    }
  }

  Future<bool> toggle(int adId) async {
    final currentIds = [...state.ids];
    final exists = currentIds.contains(adId);

    List<int> optimisticIds;
    if (exists) {
      optimisticIds = currentIds.where((e) => e != adId).toList();
    } else {
      optimisticIds = [...currentIds, adId];
    }

    state = state.copyWith(ids: optimisticIds, clearError: true);

    try {
      final isFavoriteNow = await _localStore.toggle(adId);
      final freshIds = await _localStore.getIds();

      List<AdListItem> freshItems = state.items;
      if (!isFavoriteNow) {
        freshItems = state.items.where((e) => e.id != adId).toList();
      } else {
        freshItems = await _repo.fetchByIds(freshIds);
      }

      state = state.copyWith(
        ids: freshIds,
        items: freshItems,
        clearError: true,
      );

      return isFavoriteNow;
    } catch (e) {
      state = state.copyWith(
        ids: currentIds,
        error: e.toString(),
      );
      return exists;
    }
  }

  Future<void> refresh() async {
    await load();
  }

  bool isFavorite(int adId) {
    return state.ids.contains(adId);
  }

  // ✅ BUNU ƏLAVƏ ET
  Future<List<int>> getLocalIdsOnly() async {
    return await _localStore.getIds();
  }

  // ✅ İSTƏSƏN bunu da saxla: login sonrası sync-dən sonra state yenilə
  Future<void> replaceLocalIds(List<int> ids) async {
    await _localStore.saveIds(ids);
    final items = await _repo.fetchByIds(ids);

    state = state.copyWith(
      ids: ids,
      items: items,
      clearError: true,
    );
  }
}