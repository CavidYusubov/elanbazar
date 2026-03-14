import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/store_repo.dart';
import '../models/store_models.dart';
import 'store_create_controller.dart';
final storeEditControllerProvider =
    StateNotifierProvider<StoreEditController, StoreEditState>((ref) {
  return StoreEditController(ref.read(storeRepoProvider));
});

class StoreEditState {
  final bool loading;
  final bool saving;
  final StoreDashboard? store;
  final List<StoreCity> cities;
  final String? error;
  final Map<String, String> fieldErrors;

  const StoreEditState({
    required this.loading,
    required this.saving,
    required this.store,
    required this.cities,
    required this.error,
    required this.fieldErrors,
  });

  factory StoreEditState.initial() {
    return const StoreEditState(
      loading: false,
      saving: false,
      store: null,
      cities: [],
      error: null,
      fieldErrors: {},
    );
  }

  StoreEditState copyWith({
    bool? loading,
    bool? saving,
    StoreDashboard? store,
    List<StoreCity>? cities,
    String? error,
    Map<String, String>? fieldErrors,
    bool clearError = false,
  }) {
    return StoreEditState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      store: store ?? this.store,
      cities: cities ?? this.cities,
      error: clearError ? null : (error ?? this.error),
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class StoreEditController extends StateNotifier<StoreEditState> {
  StoreEditController(this._repo) : super(StoreEditState.initial());

  final StoreRepo _repo;

  Future<void> load() async {
    state = state.copyWith(
      loading: true,
      clearError: true,
      fieldErrors: {},
    );

    try {
      final meta = await _repo.getEditMeta();
      state = state.copyWith(
        loading: false,
        cities: meta.cities,
        store: meta.store,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: _extractMessage(e),
      );
    }
  }

  Future<bool> save(StoreUpdatePayload payload) async {
    state = state.copyWith(
      saving: true,
      clearError: true,
      fieldErrors: {},
    );

    try {
      final updated = await _repo.updateStore(payload);
      state = state.copyWith(
        saving: false,
        store: updated,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        saving: false,
        error: _extractMessage(e),
        fieldErrors: _extractFieldErrors(e),
      );
      return false;
    }
  }

  Future<void> deleteGallery(int id) async {
    await _repo.deleteGalleryImage(id);
    await load();
  }

  Future<void> sortGallery(List<int> ids) async {
    await _repo.sortGallery(ids);
    await load();
  }

  String _extractMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final msg = data['message']?.toString();
        if (msg != null && msg.trim().isNotEmpty) return msg;
      }
    }
    return 'Xəta baş verdi. Yenidən cəhd edin.';
  }

  Map<String, String> _extractFieldErrors(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['errors'] is Map) {
        final raw = Map<String, dynamic>.from(data['errors'] as Map);
        final result = <String, String>{};
        for (final entry in raw.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            result[entry.key] = value.first.toString();
          }
        }
        return result;
      }
    }
    return {};
  }
}