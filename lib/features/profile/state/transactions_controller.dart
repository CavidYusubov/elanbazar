import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/account_repo.dart';
import '../data/models/account_models.dart';

final transactionsControllerProvider =
    StateNotifierProvider<TransactionsController, TransactionsState>((ref) {
  return TransactionsController(ref.read(accountRepoProvider));
});

class TransactionsState {
  final bool loading;
  final String? error;
  final String tab;
  final List<WalletTransactionItem> items;

  const TransactionsState({
    required this.loading,
    required this.error,
    required this.tab,
    required this.items,
  });

  factory TransactionsState.initial() => const TransactionsState(
        loading: true,
        error: null,
        tab: 'personal',
        items: [],
      );

  TransactionsState copyWith({
    bool? loading,
    String? error,
    String? tab,
    List<WalletTransactionItem>? items,
    bool clearError = false,
  }) {
    return TransactionsState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      tab: tab ?? this.tab,
      items: items ?? this.items,
    );
  }
}

class TransactionsController extends StateNotifier<TransactionsState> {
  final AccountRepo _repo;

  TransactionsController(this._repo) : super(TransactionsState.initial()) {
    init();
  }

  Future<void> init() async {
    try {
      state = state.copyWith(loading: true, clearError: true);
      final res = await _repo.fetchTransactions(tab: state.tab);
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

  Future<void> changeTab(String tab) async {
    try {
      state = state.copyWith(
        tab: tab,
        loading: true,
        clearError: true,
      );

      final res = await _repo.fetchTransactions(tab: tab);

      state = state.copyWith(
        loading: false,
        items: res.items,
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