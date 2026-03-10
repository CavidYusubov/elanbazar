import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/models/auth_user.dart';
import '../../auth/state/auth_controller.dart';
import '../data/account_repo.dart';
import '../data/models/account_models.dart';

final accountRepoProvider = Provider((ref) => AccountRepo());

final accountControllerProvider =
    StateNotifierProvider<AccountController, AccountState>((ref) {
  return AccountController(
    ref,
    ref.read(accountRepoProvider),
  );
});

class AccountState {
  final bool loading;
  final bool saving;
  final String tab;
  final String? error;
  final AccountResponse? account;
  final List<AccountAdItem> ads;

  const AccountState({
    required this.loading,
    required this.saving,
    required this.tab,
    required this.error,
    required this.account,
    required this.ads,
  });

  factory AccountState.initial() => const AccountState(
        loading: true,
        saving: false,
        tab: 'live',
        error: null,
        account: null,
        ads: [],
      );

  AccountState copyWith({
    bool? loading,
    bool? saving,
    String? tab,
    String? error,
    AccountResponse? account,
    List<AccountAdItem>? ads,
    bool clearError = false,
  }) {
    return AccountState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      tab: tab ?? this.tab,
      error: clearError ? null : (error ?? this.error),
      account: account ?? this.account,
      ads: ads ?? this.ads,
    );
  }
}

class AccountController extends StateNotifier<AccountState> {
  final Ref ref;
  final AccountRepo _repo;

  AccountController(this.ref, this._repo) : super(AccountState.initial()) {
    init();
  }

  Future<void> init() async {
    try {
      state = state.copyWith(loading: true, clearError: true);

      final account = await _repo.fetchAccount();
      final ads = await _repo.fetchAds(tab: state.tab);

      state = state.copyWith(
        loading: false,
        account: account,
        ads: ads,
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

  Future<void> changeTab(String tab) async {
    try {
      state = state.copyWith(
        tab: tab,
        loading: true,
        clearError: true,
      );

      final account = await _repo.fetchAccount();
      final ads = await _repo.fetchAds(tab: tab);

      state = state.copyWith(
        loading: false,
        account: account,
        ads: ads,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> archiveAd(int adId) async {
    try {
      state = state.copyWith(saving: true, clearError: true);
      await _repo.archiveAd(adId);
      await init();
      state = state.copyWith(saving: false);
    } catch (e) {
      state = state.copyWith(
        saving: false,
        error: e.toString(),
      );
    }
  }

  Future<void> restoreAd(int adId) async {
    try {
      state = state.copyWith(saving: true, clearError: true);
      await _repo.restoreAd(adId);
      await init();
      state = state.copyWith(saving: false);
    } catch (e) {
      state = state.copyWith(
        saving: false,
        error: e.toString(),
      );
    }
  }

  Future<void> uploadPhoto(File file) async {
    final acc = state.account;
    if (acc == null) return;

    try {
      state = state.copyWith(saving: true, clearError: true);

      final updatedUser = await _repo.uploadPhoto(file);
      _patchEverywhere(updatedUser);

      state = state.copyWith(saving: false);
    } catch (e) {
      state = state.copyWith(
        saving: false,
        error: e.toString(),
      );
    }
  }

  Future<void> saveProfile({
    required String name,
    String? phone,
  }) async {
    try {
      state = state.copyWith(saving: true, clearError: true);
      final updatedUser = await _repo.updateProfile(name: name, phone: phone);
      _patchEverywhere(updatedUser);
      state = state.copyWith(saving: false);
    } catch (e) {
      state = state.copyWith(saving: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> saveEmail(String email) async {
    try {
      state = state.copyWith(saving: true, clearError: true);
      final updatedUser = await _repo.updateEmail(email: email);
      _patchEverywhere(updatedUser);
      state = state.copyWith(saving: false);
    } catch (e) {
      state = state.copyWith(saving: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> savePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      state = state.copyWith(saving: true, clearError: true);
      await _repo.updatePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = state.copyWith(saving: false);
    } catch (e) {
      state = state.copyWith(saving: false, error: e.toString());
      rethrow;
    }
  }

  void _patchEverywhere(AccountUser updatedUser) {
    final acc = state.account;
    if (acc == null) return;

    final patched = AccountResponse(
      user: updatedUser,
      balance: acc.balance,
      followingCount: acc.followingCount,
      followersCount: acc.followersCount,
      counts: acc.counts,
      walletMenu: acc.walletMenu,
    );

    state = state.copyWith(account: patched);

    ref.read(authControllerProvider.notifier).patchUser(
          AuthUser(
            id: updatedUser.id,
            name: updatedUser.name,
            email: updatedUser.email,
            phone: updatedUser.phone,
            photoUrl: updatedUser.photoUrl,
            store: updatedUser.store == null
                ? null
                : AuthStoreMini(
                    id: updatedUser.store!.id,
                    name: updatedUser.store!.name,
                    slug: updatedUser.store!.slug,
                  ),
          ),
        );
  }
}