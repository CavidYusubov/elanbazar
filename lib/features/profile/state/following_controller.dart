import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/account_repo.dart';
import '../data/models/account_models.dart';

final followingControllerProvider =
    StateNotifierProvider<FollowingController, FollowingState>((ref) {
  return FollowingController(ref.read(accountRepoProvider));
});

class FollowingState {
  final bool loading;
  final String? error;
  final List<FollowItem> items;

  const FollowingState({
    required this.loading,
    required this.error,
    required this.items,
  });

  factory FollowingState.initial() => const FollowingState(
        loading: true,
        error: null,
        items: [],
      );

  FollowingState copyWith({
    bool? loading,
    String? error,
    List<FollowItem>? items,
    bool clearError = false,
  }) {
    return FollowingState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
    );
  }
}

class FollowingController extends StateNotifier<FollowingState> {
  final AccountRepo _repo;

  FollowingController(this._repo) : super(FollowingState.initial()) {
    init();
  }

  Future<void> init() async {
    try {
      state = state.copyWith(loading: true, clearError: true);
      final res = await _repo.fetchFollowing();
      state = state.copyWith(
        loading: false,
        items: res.items,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshAll() async {
    await init();
  }
}