import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ad_create_repo.dart';
import '../models/ad_create_attribute.dart';
import '../models/ad_create_category.dart';
import '../models/ad_create_city.dart';
import '../models/ad_create_request.dart';
import 'ad_create_state.dart';

final adCreateRepoProvider = Provider<AdCreateRepo>((ref) {
  return AdCreateRepo();
});

final adCreateControllerProvider =
    StateNotifierProvider<AdCreateController, AdCreateState>((ref) {
  final repo = ref.watch(adCreateRepoProvider);
  return AdCreateController(repo);
});

class AdCreateController extends StateNotifier<AdCreateState> {
  final AdCreateRepo repo;

  static const int maxImages = 20;

  AdCreateController(this.repo) : super(AdCreateState.initial());

  Future<void> init() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final meta = await repo.fetchCreateMeta();
      final roots = await repo.fetchRootCategories();

      state = state.copyWith(
        isLoading: false,
        meta: meta,
        roots: roots,
        selectedCity: meta.cities.isNotEmpty ? meta.cities.first : null,
        currency: meta.currencies.isNotEmpty ? meta.currencies.first : 'AZN',
        condition: meta.conditions.contains('used')
            ? 'used'
            : (meta.conditions.isNotEmpty ? meta.conditions.first : 'used'),
        contactMethod: meta.contactMethods.contains('calls_messages')
            ? 'calls_messages'
            : (meta.contactMethods.isNotEmpty ? meta.contactMethods.first : 'calls_messages'),
        contactName: meta.contact.name ?? '',
        contactEmail: meta.contact.email ?? '',
        contactPhone: meta.contact.phone ?? '',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> selectRoot(AdCreateCategory category) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedRoot: category,
      selectedLevel2: null,
      selectedLeaf: null,
      level2: [],
      level3: [],
      attributes: [],
      attributeValues: {},
    );

    try {
      final children = await repo.fetchChildren(category.id);
      state = state.copyWith(
        isLoading: false,
        level2: children,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
    }
  }

  Future<void> selectLevel2(AdCreateCategory category) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedLevel2: category,
      selectedLeaf: null,
      level3: [],
      attributes: [],
      attributeValues: {},
    );

    try {
      final children = await repo.fetchChildren(category.id);

      if (children.isEmpty) {
        final attrs = await repo.fetchAttributes(category.id);
        state = state.copyWith(
          isLoading: false,
          selectedLeaf: category,
          level3: [],
          attributes: attrs,
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        level3: children,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
    }
  }

  Future<void> selectLeaf(AdCreateCategory category) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedLeaf: category,
      attributes: [],
      attributeValues: {},
    );

    try {
      final attrs = await repo.fetchAttributes(category.id);
      state = state.copyWith(
        isLoading: false,
        attributes: attrs,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
    }
  }

  void setCity(AdCreateCity? city) {
    if (city == null) return;
    state = state.copyWith(selectedCity: city);
  }

  void setPrice(String value) => state = state.copyWith(price: value);
  void setCurrency(String value) => state = state.copyWith(currency: value);
  void setCondition(String value) => state = state.copyWith(condition: value);
  void setDescription(String value) => state = state.copyWith(description: value);
  void setContactName(String value) => state = state.copyWith(contactName: value);
  void setContactEmail(String value) => state = state.copyWith(contactEmail: value);
  void setContactPhone(String value) => state = state.copyWith(contactPhone: value);
  void setContactMethod(String value) => state = state.copyWith(contactMethod: value);
  void setHasDelivery(bool value) => state = state.copyWith(hasDelivery: value);
  void setPostAsStore(bool value) => state = state.copyWith(postAsStore: value);

  void setAttributeValue(int attrId, dynamic value) {
    final next = Map<int, dynamic>.from(state.attributeValues);
    next[attrId] = value;
    state = state.copyWith(attributeValues: next, clearError: true);
    _cleanupDependentFields();
  }

  dynamic getAttributeValue(int attrId) => state.attributeValues[attrId];

  bool isAttributeVisible(int attrId) {
    final attr = _findAttribute(attrId);
    if (attr == null) return false;
    if (attr.dependency == null) return true;

    final dep = attr.dependency!;
    final parentValue = state.attributeValues[dep.parentAttributeId];
    if (parentValue == null) return false;

    if (parentValue is List) {
      return parentValue.any((item) {
        final s = item.toString();
        return (dep.parentOptionId != null && s == dep.parentOptionId) ||
            (dep.parentOptionValue != null && s == dep.parentOptionValue);
      });
    }

    final one = parentValue.toString();
    return (dep.parentOptionId != null && one == dep.parentOptionId) ||
        (dep.parentOptionValue != null && one == dep.parentOptionValue);
  }

  void addImages(List<File> files) {
    if (files.isEmpty) return;

    final current = [...state.images];
    final room = maxImages - current.length;

    if (room <= 0) {
      state = state.copyWith(
        error: 'Maksimum $maxImages şəkil əlavə etmək olar.',
      );
      return;
    }

    final take = files.take(room).toList();
    current.addAll(take);

    String? error;
    if (files.length > room) {
      error = 'Yalnız $maxImages şəkilə qədər icazə verilir.';
    }

    state = state.copyWith(
      images: current,
      error: error,
    );
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= state.images.length) return;

    final next = [...state.images]..removeAt(index);
    var coverIndex = state.coverIndex;

    if (next.isEmpty) {
      coverIndex = 0;
    } else if (coverIndex >= next.length) {
      coverIndex = 0;
    } else if (index < coverIndex) {
      coverIndex -= 1;
    }

    state = state.copyWith(
      images: next,
      coverIndex: coverIndex,
    );
  }

  void setCoverIndex(int index) {
    if (index < 0 || index >= state.images.length) return;
    state = state.copyWith(coverIndex: index);
  }

  void reorderImages(int oldIndex, int newIndex) {
    final list = [...state.images];
    if (oldIndex < 0 || oldIndex >= list.length) return;
    if (newIndex < 0 || newIndex > list.length) return;

    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    int cover = state.coverIndex;
    if (cover == oldIndex) {
      cover = newIndex;
    } else if (oldIndex < cover && newIndex >= cover) {
      cover -= 1;
    } else if (oldIndex > cover && newIndex <= cover) {
      cover += 1;
    }

    state = state.copyWith(
      images: list,
      coverIndex: cover,
    );
  }

  Future<bool> submit() async {
    final leaf = state.selectedLeaf;
    final city = state.selectedCity;

    if (leaf == null) {
      state = state.copyWith(error: 'Kateqoriya seçilməyib.');
      return false;
    }

    if (city == null) {
      state = state.copyWith(error: 'Şəhər seçilməyib.');
      return false;
    }

    if (state.images.isEmpty) {
      state = state.copyWith(error: 'Ən azı 1 şəkil əlavə edilməlidir.');
      return false;
    }

    final price = int.tryParse(state.price.trim());
    if (price == null || price < 0) {
      state = state.copyWith(error: 'Qiymət düzgün deyil.');
      return false;
    }

    for (final attr in state.attributes) {
      if (!isAttributeVisible(attr.id)) continue;
      if (!attr.required) continue;

      final value = state.attributeValues[attr.id];
      final empty = value == null ||
          (value is String && value.trim().isEmpty) ||
          (value is List && value.isEmpty);

      if (empty) {
        state = state.copyWith(error: '${attr.name} doldurulmalıdır.');
        return false;
      }
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final req = AdCreateRequest(
        categoryId: leaf.id,
        cityId: city.id,
        price: price,
        currency: state.currency,
        condition: state.condition,
        description: state.description.trim().isEmpty ? null : state.description.trim(),
        contactName: state.contactName.trim().isEmpty ? null : state.contactName.trim(),
        contactEmail: state.contactEmail.trim().isEmpty ? null : state.contactEmail.trim(),
        contactPhone: state.contactPhone.trim().isEmpty ? null : state.contactPhone.trim(),
        contactMethod: state.contactMethod.trim().isEmpty ? null : state.contactMethod.trim(),
        hasDelivery: state.hasDelivery,
        postAsStore: state.postAsStore,
        coverIndex: state.coverIndex,
        attributes: state.attributeValues.map((k, v) => MapEntry(k.toString(), v)),
        images: state.images.map((e) => AdCreateImageFile(file: e)).toList(),
      );

      await repo.submit(req);

      state = state.copyWith(isSubmitting: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: _extractError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void _cleanupDependentFields() {
    final next = Map<int, dynamic>.from(state.attributeValues);

    for (final attr in state.attributes) {
      if (attr.dependency == null) continue;
      if (!isAttributeVisible(attr.id)) {
        next.remove(attr.id);
      }
    }

    state = state.copyWith(attributeValues: next);
  }

  AdCreateAttribute? _findAttribute(int id) {
    for (final item in state.attributes) {
      if (item.id == id) return item;
    }
    return null;
  }

  String _extractError(DioException e) {
    final body = e.response?.data;

    if (body is Map) {
      final message = body['message'];
      final errors = body['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final lines = <String>[];

        errors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            for (final item in value) {
              lines.add(item.toString());
            }
          } else if (value != null) {
            lines.add(value.toString());
          }
        });

        if (lines.isNotEmpty) {
          return lines.join('\n');
        }
      }

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Bağlantı vaxtı bitdi. Yenidən yoxla.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Serverə qoşulmaq olmadı.';
    }

    return 'Xəta baş verdi.';
  }

  void resetCategoryUiOnly() {
  state = state.copyWith(
    level2: [],
    level3: [],
    clearError: true,
  );
}

void clearSelectedCategory() {
  state = state.copyWith(
    selectedRoot: null,
    selectedLevel2: null,
    selectedLeaf: null,
    level2: [],
    level3: [],
    attributes: [],
    attributeValues: {},
    clearError: true,
  );
}
}