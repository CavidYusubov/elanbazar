import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/store_repo.dart';
import '../models/store_models.dart';
import 'store_create_controller.dart';

final storeDashboardControllerProvider =
    StateNotifierProvider<StoreDashboardController, StoreDashboardState>((ref) {
  return StoreDashboardController(ref.read(storeRepoProvider));
});

class StoreDashboardState {
  final bool loading;
  final StoreDashboard? store;
  final String? error;

  const StoreDashboardState({
    required this.loading,
    required this.store,
    required this.error,
  });

  factory StoreDashboardState.initial() {
    return const StoreDashboardState(
      loading: false,
      store: null,
      error: null,
    );
  }

  StoreDashboardState copyWith({
    bool? loading,
    StoreDashboard? store,
    String? error,
    bool clearError = false,
  }) {
    return StoreDashboardState(
      loading: loading ?? this.loading,
      store: store ?? this.store,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class StoreDashboardController extends StateNotifier<StoreDashboardState> {
  StoreDashboardController(this._repo) : super(StoreDashboardState.initial());

  final StoreRepo _repo;

  Future<void> load() async {
    state = state.copyWith(
      loading: true,
      clearError: true,
    );

    try {
      final store = await _repo.getDashboard();
      state = state.copyWith(
        loading: false,
        store: store,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: _extractMessage(e),
      );
    }
  }

  String _extractMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;

      if (data is Map) {
        final msg = data['message']?.toString();
        if (msg != null && msg.trim().isNotEmpty) {
          return msg;
        }
      }

      if (e.response?.statusCode == 404) {
        return 'Hələ mağazanız yoxdur.';
      }
    }

    return 'Xəta baş verdi. Yenidən cəhd edin.';
  }
}