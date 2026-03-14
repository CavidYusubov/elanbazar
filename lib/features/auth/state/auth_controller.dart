import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/token_store.dart';
import '../../../core/network/api_client.dart';
import '../../favorites/state/favorites_controller.dart';
import '../data/auth_repo.dart';
import '../data/models/auth_user.dart';

final tokenStoreProvider = Provider((ref) => TokenStore());
final authRepoProvider = Provider((ref) => AuthRepo());

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref,
    ref.read(authRepoProvider),
    ref.read(tokenStoreProvider),
  );
});

class AuthState {
  final bool loading;
  final bool initialized;
  final bool authenticated;
  final AuthUser? user;
  final String? error;

  const AuthState({
    required this.loading,
    required this.initialized,
    required this.authenticated,
    required this.user,
    required this.error,
  });

  factory AuthState.initial() => const AuthState(
        loading: false,
        initialized: false,
        authenticated: false,
        user: null,
        error: null,
      );

  AuthState copyWith({
    bool? loading,
    bool? initialized,
    bool? authenticated,
    AuthUser? user,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      initialized: initialized ?? this.initialized,
      authenticated: authenticated ?? this.authenticated,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.ref, this._repo, this._tokenStore)
      : super(AuthState.initial()) {
    bootstrap();
  }

  final Ref ref;
  final AuthRepo _repo;
  final TokenStore _tokenStore;

  Future<void> bootstrap() async {
    try {
      final token = await _tokenStore.readToken();

      if (token == null || token.isEmpty) {
        state = state.copyWith(initialized: true, authenticated: false, clearUser: true);
        return;
      }

      ApiClient.I.setToken(token);

      final user = await _repo.me();

      state = state.copyWith(
        initialized: true,
        authenticated: true,
        user: user,
        clearError: true,
      );
    } catch (_) {
      await _tokenStore.clearToken();
      ApiClient.I.setToken(null);

      state = state.copyWith(
        initialized: true,
        authenticated: false,
        clearUser: true,
        error: null,
      );
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final result = await _repo.loginWithEmail(
        email: email,
        password: password,
      );

      await _tokenStore.saveToken(result.token);
      ApiClient.I.setToken(result.token);

      state = state.copyWith(
        loading: false,
        authenticated: true,
        user: result.user,
        initialized: true,
        clearError: true,
      );

      await _syncLocalFavorites();
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendOtp({
    required String phone,
  }) async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      await _repo.sendOtp(phone: phone);
      state = state.copyWith(loading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

void patchUser(AuthUser user) {
  state = state.copyWith(
    user: user,
    authenticated: true,
    initialized: true,
    clearError: true,
  );
}

Future<void> refreshMe() async {
  try {
    final user = await _repo.me();

    state = state.copyWith(
      user: user,
      authenticated: true,
      initialized: true,
      loading: false,
      clearError: true,
    );
  } catch (e) {
    state = state.copyWith(
      loading: false,
    );
  }
}
  Future<void> verifyOtp({
    required String phone,
    required String code,
  }) async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final result = await _repo.verifyOtp(phone: phone, code: code);

      await _tokenStore.saveToken(result.token);
      ApiClient.I.setToken(result.token);

      state = state.copyWith(
        loading: false,
        authenticated: true,
        user: result.user,
        initialized: true,
        clearError: true,
      );

      await _syncLocalFavorites();
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(loading: true, clearError: true);

    try {
      final result = await _repo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      await _tokenStore.saveToken(result.token);
      ApiClient.I.setToken(result.token);

      state = state.copyWith(
        loading: false,
        authenticated: true,
        user: result.user,
        initialized: true,
        clearError: true,
      );

      await _syncLocalFavorites();
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}

    await _tokenStore.clearToken();
    ApiClient.I.setToken(null);

    state = state.copyWith(
      authenticated: false,
      clearUser: true,
      clearError: true,
      initialized: true,
      loading: false,
    );
  }

  Future<void> _syncLocalFavorites() async {
    try {
      final ids =
          await ref.read(favoritesControllerProvider.notifier).getLocalIdsOnly();
      if (ids.isEmpty) return;

      await _repo.syncFavorites(ids);
    } catch (_) {}
  }
}