import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/store_repo.dart';
import '../models/store_models.dart';

final storeRepoProvider = Provider<StoreRepo>((ref) {
  return StoreRepo();
});

final storeCreateControllerProvider =
    StateNotifierProvider<StoreCreateController, StoreCreateState>((ref) {
  return StoreCreateController(ref.read(storeRepoProvider));
});

class StoreCreateState {
  final bool metaLoading;
  final bool submitting;
  final List<StoreCity> cities;
  final StoreDetail? createdStore;
  final String? error;
  final Map<String, String> fieldErrors;

  const StoreCreateState({
    required this.metaLoading,
    required this.submitting,
    required this.cities,
    required this.createdStore,
    required this.error,
    required this.fieldErrors,
  });

  factory StoreCreateState.initial() {
    return const StoreCreateState(
      metaLoading: false,
      submitting: false,
      cities: [],
      createdStore: null,
      error: null,
      fieldErrors: {},
    );
  }

  StoreCreateState copyWith({
    bool? metaLoading,
    bool? submitting,
    List<StoreCity>? cities,
    StoreDetail? createdStore,
    String? error,
    Map<String, String>? fieldErrors,
    bool clearError = false,
    bool clearCreatedStore = false,
  }) {
    return StoreCreateState(
      metaLoading: metaLoading ?? this.metaLoading,
      submitting: submitting ?? this.submitting,
      cities: cities ?? this.cities,
      createdStore: clearCreatedStore ? null : (createdStore ?? this.createdStore),
      error: clearError ? null : (error ?? this.error),
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class StoreCreateController extends StateNotifier<StoreCreateState> {
  StoreCreateController(this._repo) : super(StoreCreateState.initial());

  final StoreRepo _repo;

  Future<void> loadMeta() async {
    if (state.metaLoading || state.cities.isNotEmpty) return;

    state = state.copyWith(
      metaLoading: true,
      clearError: true,
      fieldErrors: {},
    );

    try {
      final meta = await _repo.getMeta();
      state = state.copyWith(
        metaLoading: false,
        cities: meta.cities,
      );
    } catch (e) {
      state = state.copyWith(
        metaLoading: false,
        error: _extractMessage(e),
      );
    }
  }

  Future<StoreDetail?> submit(StoreCreatePayload payload) async {
    state = state.copyWith(
      submitting: true,
      clearError: true,
      fieldErrors: {},
      clearCreatedStore: true,
    );

    try {
      final store = await _repo.createStore(payload);
      state = state.copyWith(
        submitting: false,
        createdStore: store,
      );
      return store;
    } catch (e) {
      state = state.copyWith(
        submitting: false,
        error: _extractMessage(e),
        fieldErrors: _extractFieldErrors(e),
      );
      return null;
    }
  }

  void clearErrors() {
    state = state.copyWith(
      clearError: true,
      fieldErrors: {},
    );
  }

  String _extractMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;

      if (data is Map) {
        final message = data['message']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          return message;
        }
      }

      if (e.response?.statusCode == 409) {
        return 'Sizin artıq mağazanız var.';
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
          } else if (value != null) {
            result[entry.key] = value.toString();
          }
        }

        return result;
      }
    }

    return {};
  }
}