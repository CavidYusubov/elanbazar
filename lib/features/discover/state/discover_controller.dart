import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/discover_repo.dart';
import '../data/models/ad_list_item.dart';

final discoverRepoProvider = Provider((ref) => DiscoverRepo());

final discoverControllerProvider =
    StateNotifierProvider<DiscoverController, DiscoverState>((ref) {
  return DiscoverController(ref.read(discoverRepoProvider));
});

class DiscoverState {
  final bool loading;
  final bool loadingMore;
  final List<AdListItem> items;

  final String scope;
  final String? nextCursor;
  final bool hasMore;

  final String? error;

  const DiscoverState({
    required this.loading,
    required this.loadingMore,
    required this.items,
    required this.scope,
    required this.nextCursor,
    required this.hasMore,
    this.error,
  });

  factory DiscoverState.initial() => const DiscoverState(
        loading: true,
        loadingMore: false,
        items: [],
        scope: 'all',
        nextCursor: null,
        hasMore: true,
        error: null,
      );
}

class DiscoverController extends StateNotifier<DiscoverState> {
  DiscoverController(this._repo) : super(DiscoverState.initial()) {
    loadInitial();
  }

  final DiscoverRepo _repo;
  bool _busy = false;

  Future<void> loadInitial() async {
    if (_busy) return;
    _busy = true;
    state = DiscoverState(
      loading: true,
      loadingMore: false,
      items: const [],
      scope: state.scope,
      nextCursor: null,
      hasMore: true,
      error: null,
    );

    try {
      final r = await _repo.fetchAds(scope: state.scope, cursor: null);
      state = DiscoverState(
        loading: false,
        loadingMore: false,
        items: r.items,
        scope: state.scope,
        nextCursor: r.nextCursor,
        hasMore: r.hasMore,
        error: null,
      );
    } catch (e) {
      state = DiscoverState(
        loading: false,
        loadingMore: false,
        items: const [],
        scope: state.scope,
        nextCursor: null,
        hasMore: false,
        error: e.toString(),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> refresh() => loadInitial();

  Future<void> loadMore() async {
    if (_busy) return;
    if (!state.hasMore) return;
    if (state.nextCursor == null || state.nextCursor!.isEmpty) return;

    _busy = true;
    state = DiscoverState(
      loading: state.loading,
      loadingMore: true,
      items: state.items,
      scope: state.scope,
      nextCursor: state.nextCursor,
      hasMore: state.hasMore,
      error: state.error,
    );

    try {
      final r = await _repo.fetchAds(scope: state.scope, cursor: state.nextCursor);
      state = DiscoverState(
        loading: false,
        loadingMore: false,
        items: [...state.items, ...r.items],
        scope: state.scope,
        nextCursor: r.nextCursor,
        hasMore: r.hasMore,
        error: null,
      );
    } catch (e) {
      state = DiscoverState(
        loading: false,
        loadingMore: false,
        items: state.items,
        scope: state.scope,
        nextCursor: state.nextCursor,
        hasMore: state.hasMore,
        error: e.toString(),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> setScope(String scope) async {
    if (scope == state.scope) return;
    state = DiscoverState(
      loading: true,
      loadingMore: false,
      items: const [],
      scope: scope,
      nextCursor: null,
      hasMore: true,
      error: null,
    );
    await loadInitial();
  }
}