import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/account_repo.dart';
import '../data/models/account_models.dart';

final walletControllerProvider =
    StateNotifierProvider<WalletController, WalletState>((ref) {
  return WalletController(ref.read(accountRepoProvider));
});

class WalletState {
  final bool loading;
  final String? error;
  final WalletResponse? wallet;

  const WalletState({
    required this.loading,
    required this.error,
    required this.wallet,
  });

  factory WalletState.initial() => const WalletState(
        loading: true,
        error: null,
        wallet: null,
      );

  WalletState copyWith({
    bool? loading,
    String? error,
    WalletResponse? wallet,
    bool clearError = false,
  }) {
    return WalletState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      wallet: wallet ?? this.wallet,
    );
  }
}

class WalletController extends StateNotifier<WalletState> {
  final AccountRepo _repo;

  WalletController(this._repo) : super(WalletState.initial()) {
    init();
  }

  Future<void> init() async {
    try {
      state = state.copyWith(loading: true, clearError: true);
      final wallet = await _repo.fetchWallet();
      state = state.copyWith(
        loading: false,
        wallet: wallet,
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