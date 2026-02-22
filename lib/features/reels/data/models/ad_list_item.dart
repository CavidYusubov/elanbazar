import 'package:freezed_annotation/freezed_annotation.dart';
part 'ad_list_item.freezed.dart';
part 'ad_list_item.g.dart';

@freezed
class AdListItem with _$AdListItem {
  const factory AdListItem({
    required int id,
    required String title,
    required double price,
    required String currency,
    required String coverUrl,
    required String createdAt,
    required CityMini city,
    required CategoryMini category,
    StoreMini? store,
    @Default(false) bool isVipActive,
    @Default(false) bool isPremiumActive,
  }) = _AdListItem;

  factory AdListItem.fromJson(Map<String, dynamic> json) => _$AdListItemFromJson(json);
}

@freezed
class CityMini with _$CityMini {
  const factory CityMini({required int id, required String name}) = _CityMini;
  factory CityMini.fromJson(Map<String, dynamic> json) => _$CityMiniFromJson(json);
}

@freezed
class CategoryMini with _$CategoryMini {
  const factory CategoryMini({required int id, required String name, required String slug}) = _CategoryMini;
  factory CategoryMini.fromJson(Map<String, dynamic> json) => _$CategoryMiniFromJson(json);
}

@freezed
class StoreMini with _$StoreMini {
  const factory StoreMini({required int id, required String name, required String slug}) = _StoreMini;
  factory StoreMini.fromJson(Map<String, dynamic> json) => _$StoreMiniFromJson(json);
}