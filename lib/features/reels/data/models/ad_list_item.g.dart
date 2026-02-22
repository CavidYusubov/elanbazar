// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdListItemImpl _$$AdListItemImplFromJson(Map<String, dynamic> json) =>
    _$AdListItemImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      coverUrl: json['coverUrl'] as String,
      createdAt: json['createdAt'] as String,
      city: CityMini.fromJson(json['city'] as Map<String, dynamic>),
      category: CategoryMini.fromJson(json['category'] as Map<String, dynamic>),
      store: json['store'] == null
          ? null
          : StoreMini.fromJson(json['store'] as Map<String, dynamic>),
      isVipActive: json['isVipActive'] as bool? ?? false,
      isPremiumActive: json['isPremiumActive'] as bool? ?? false,
    );

Map<String, dynamic> _$$AdListItemImplToJson(_$AdListItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price': instance.price,
      'currency': instance.currency,
      'coverUrl': instance.coverUrl,
      'createdAt': instance.createdAt,
      'city': instance.city,
      'category': instance.category,
      'store': instance.store,
      'isVipActive': instance.isVipActive,
      'isPremiumActive': instance.isPremiumActive,
    };

_$CityMiniImpl _$$CityMiniImplFromJson(Map<String, dynamic> json) =>
    _$CityMiniImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$$CityMiniImplToJson(_$CityMiniImpl instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_$CategoryMiniImpl _$$CategoryMiniImplFromJson(Map<String, dynamic> json) =>
    _$CategoryMiniImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
    );

Map<String, dynamic> _$$CategoryMiniImplToJson(_$CategoryMiniImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };

_$StoreMiniImpl _$$StoreMiniImplFromJson(Map<String, dynamic> json) =>
    _$StoreMiniImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
    );

Map<String, dynamic> _$$StoreMiniImplToJson(_$StoreMiniImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
    };
