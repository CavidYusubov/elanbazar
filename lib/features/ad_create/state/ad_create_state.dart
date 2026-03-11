import 'dart:io';

import '../models/ad_create_attribute.dart';
import '../models/ad_create_category.dart';
import '../models/ad_create_city.dart';
import '../models/ad_create_meta.dart';

class AdCreateState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  final AdCreateMeta? meta;
  final List<AdCreateCategory> roots;
  final List<AdCreateCategory> level2;
  final List<AdCreateCategory> level3;
  final List<AdCreateAttribute> attributes;

  final AdCreateCategory? selectedRoot;
  final AdCreateCategory? selectedLevel2;
  final AdCreateCategory? selectedLeaf;
  final AdCreateCity? selectedCity;

  final String price;
  final String currency;
  final String condition;
  final String description;
  final String contactName;
  final String contactEmail;
  final String contactPhone;
  final String contactMethod;
  final bool hasDelivery;
  final bool postAsStore;

  final Map<int, dynamic> attributeValues;
  final List<File> images;
  final int coverIndex;

  const AdCreateState({
    required this.isLoading,
    required this.isSubmitting,
    required this.error,
    required this.meta,
    required this.roots,
    required this.level2,
    required this.level3,
    required this.attributes,
    required this.selectedRoot,
    required this.selectedLevel2,
    required this.selectedLeaf,
    required this.selectedCity,
    required this.price,
    required this.currency,
    required this.condition,
    required this.description,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    required this.contactMethod,
    required this.hasDelivery,
    required this.postAsStore,
    required this.attributeValues,
    required this.images,
    required this.coverIndex,
  });

  factory AdCreateState.initial() {
    return const AdCreateState(
      isLoading: false,
      isSubmitting: false,
      error: null,
      meta: null,
      roots: [],
      level2: [],
      level3: [],
      attributes: [],
      selectedRoot: null,
      selectedLevel2: null,
      selectedLeaf: null,
      selectedCity: null,
      price: '',
      currency: 'AZN',
      condition: 'used',
      description: '',
      contactName: '',
      contactEmail: '',
      contactPhone: '',
      contactMethod: 'calls_messages',
      hasDelivery: false,
      postAsStore: false,
      attributeValues: {},
      images: [],
      coverIndex: 0,
    );
  }

  AdCreateState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    AdCreateMeta? meta,
    List<AdCreateCategory>? roots,
    List<AdCreateCategory>? level2,
    List<AdCreateCategory>? level3,
    List<AdCreateAttribute>? attributes,
    AdCreateCategory? selectedRoot,
    AdCreateCategory? selectedLevel2,
    AdCreateCategory? selectedLeaf,
    AdCreateCity? selectedCity,
    String? price,
    String? currency,
    String? condition,
    String? description,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? contactMethod,
    bool? hasDelivery,
    bool? postAsStore,
    Map<int, dynamic>? attributeValues,
    List<File>? images,
    int? coverIndex,
  }) {
    return AdCreateState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      meta: meta ?? this.meta,
      roots: roots ?? this.roots,
      level2: level2 ?? this.level2,
      level3: level3 ?? this.level3,
      attributes: attributes ?? this.attributes,
      selectedRoot: selectedRoot ?? this.selectedRoot,
      selectedLevel2: selectedLevel2 ?? this.selectedLevel2,
      selectedLeaf: selectedLeaf ?? this.selectedLeaf,
      selectedCity: selectedCity ?? this.selectedCity,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      contactMethod: contactMethod ?? this.contactMethod,
      hasDelivery: hasDelivery ?? this.hasDelivery,
      postAsStore: postAsStore ?? this.postAsStore,
      attributeValues: attributeValues ?? this.attributeValues,
      images: images ?? this.images,
      coverIndex: coverIndex ?? this.coverIndex,
    );
  }
}