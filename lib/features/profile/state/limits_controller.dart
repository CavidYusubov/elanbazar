import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/account_repo.dart';
import '../data/models/account_models.dart';

final limitsControllerProvider =
    StateNotifierProvider<LimitsController, LimitsState>((ref) {
  return LimitsController(ref.read(accountRepoProvider));
});

class LimitsState {
  final bool loading;
  final String? error;
  final List<LimitItem> items;
  final Set<int> openedIds;

  const LimitsState({
    required this.loading,
    required this.error,
    required this.items,
    required this.openedIds,
  });

  factory LimitsState.initial() => const LimitsState(
        loading: true,
        error: null,
        items: [],
        openedIds: {},
      );

  LimitsState copyWith({
    bool? loading,
    String? error,
    List<LimitItem>? items,
    Set<int>? openedIds,
    bool clearError = false,
  }) {
    return LimitsState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
      openedIds: openedIds ?? this.openedIds,
    );
  }
}

class LimitsController extends StateNotifier<LimitsState> {
  final AccountRepo _repo;

  LimitsController(this._repo) : super(LimitsState.initial()) {
    init();
  }

  Future<void> init() async {
    try {
      state = state.copyWith(loading: true, clearError: true);
      final items = await _repo.fetchLimits();
      state = state.copyWith(
        loading: false,
        items: items,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  void toggleOpen(int id) {
    final next = <int>{...state.openedIds};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(openedIds: next);
  }

  Future<void> refreshAll() async {
    await init();
  }
}