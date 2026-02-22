import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_profile_repo.dart';
import '../../discover/data/models/ad_list_item.dart';

final userProfileRepoProvider = Provider((ref) => UserProfileRepo());

final userProfileControllerProvider =
    StateNotifierProvider.family<UserProfileController, UserProfileState, int>((ref, userId) {
  return UserProfileController(ref.read(userProfileRepoProvider), userId);
});

class UserProfileState {
  final bool loading;
  final bool loadingMore;
  final List<AdListItem> ads;
  final String? nextCursor;
  final bool hasMore;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? stats;
  final String? error;
  final bool gridView;

  const UserProfileState({
    required this.loading,
    required this.loadingMore,
    required this.ads,
    required this.nextCursor,
    required this.hasMore,
    this.user,
    this.stats,
    this.error,
    required this.gridView,
  });

  factory UserProfileState.initial() => const UserProfileState(
        loading: true,
        loadingMore: false,
        ads: [],
        nextCursor: null,
        hasMore: true,
        user: null,
        stats: null,
        error: null,
        gridView: true,
      );

  UserProfileState copyWith({
    bool? loading,
    bool? loadingMore,
    List<AdListItem>? ads,
    String? nextCursor,
    bool? hasMore,
    Map<String, dynamic>? user,
    Map<String, dynamic>? stats,
    String? error,
    bool? gridView,
  }) {
    return UserProfileState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      ads: ads ?? this.ads,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      user: user ?? this.user,
      stats: stats ?? this.stats,
      error: error ?? this.error,
      gridView: gridView ?? this.gridView,
    );
  }
}

class UserProfileController extends StateNotifier<UserProfileState> {
  UserProfileController(this._repo, this.userId) : super(UserProfileState.initial()) {
    loadInitial();
  }

  final UserProfileRepo _repo;
  final int userId;
  bool _busy = false;

  Future<void> loadInitial() async {
    if (_busy) return;
    _busy = true;
    state = state.copyWith(loading: true, error: null);
    try {
      final r = await _repo.fetchProfile(userId: userId);
      state = state.copyWith(
        loading: false,
        ads: r.ads,
        nextCursor: r.nextCursor,
        hasMore: r.hasMore,
        user: r.user,
        stats: r.stats,
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
      final r = await _repo.fetchProfile(userId: userId, cursor: state.nextCursor);
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
