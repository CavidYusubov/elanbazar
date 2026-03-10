import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/account_repo.dart';
import '../data/models/account_models.dart';

final followersControllerProvider =
    StateNotifierProvider<FollowersController, FollowersState>((ref) {
  return FollowersController(ref.read(accountRepoProvider));
});

class FollowersState {
  final bool loading;
  final String? error;
  final List<FollowItem> items;

  const FollowersState({
    required this.loading,
    required this.error,
    required this.items,
  });

  factory FollowersState.initial() => const FollowersState(
        loading: true,
        error: null,
        items: [],
      );

  FollowersState copyWith({
    bool? loading,
    String? error,
    List<FollowItem>? items,
    bool clearError = false,
  }) {
    return FollowersState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
    );
  }
}

class FollowersController extends StateNotifier<FollowersState> {
  final AccountRepo _repo;

  FollowersController(this._repo) : super(FollowersState.initial()) {
    init();
  }

  Future<void> init() async {
    try {
      state = state.copyWith(loading: true, clearError: true);
      final res = await _repo.fetchFollowers();
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