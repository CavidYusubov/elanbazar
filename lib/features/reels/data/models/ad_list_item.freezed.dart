// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ad_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AdListItem _$AdListItemFromJson(Map<String, dynamic> json) {
  return _AdListItem.fromJson(json);
}

/// @nodoc
mixin _$AdListItem {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get coverUrl => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  CityMini get city => throw _privateConstructorUsedError;
  CategoryMini get category => throw _privateConstructorUsedError;
  StoreMini? get store => throw _privateConstructorUsedError;
  bool get isVipActive => throw _privateConstructorUsedError;
  bool get isPremiumActive => throw _privateConstructorUsedError;

  /// Serializes this AdListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdListItemCopyWith<AdListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdListItemCopyWith<$Res> {
  factory $AdListItemCopyWith(
    AdListItem value,
    $Res Function(AdListItem) then,
  ) = _$AdListItemCopyWithImpl<$Res, AdListItem>;
  @useResult
  $Res call({
    int id,
    String title,
    double price,
    String currency,
    String coverUrl,
    String createdAt,
    CityMini city,
    CategoryMini category,
    StoreMini? store,
    bool isVipActive,
    bool isPremiumActive,
  });

  $CityMiniCopyWith<$Res> get city;
  $CategoryMiniCopyWith<$Res> get category;
  $StoreMiniCopyWith<$Res>? get store;
}

/// @nodoc
class _$AdListItemCopyWithImpl<$Res, $Val extends AdListItem>
    implements $AdListItemCopyWith<$Res> {
  _$AdListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? price = null,
    Object? currency = null,
    Object? coverUrl = null,
    Object? createdAt = null,
    Object? city = null,
    Object? category = null,
    Object? store = freezed,
    Object? isVipActive = null,
    Object? isPremiumActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            coverUrl: null == coverUrl
                ? _value.coverUrl
                : coverUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as CityMini,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as CategoryMini,
            store: freezed == store
                ? _value.store
                : store // ignore: cast_nullable_to_non_nullable
                      as StoreMini?,
            isVipActive: null == isVipActive
                ? _value.isVipActive
                : isVipActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            isPremiumActive: null == isPremiumActive
                ? _value.isPremiumActive
                : isPremiumActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of AdListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CityMiniCopyWith<$Res> get city {
    return $CityMiniCopyWith<$Res>(_value.city, (value) {
      return _then(_value.copyWith(city: value) as $Val);
    });
  }

  /// Create a copy of AdListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryMiniCopyWith<$Res> get category {
    return $CategoryMiniCopyWith<$Res>(_value.category, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }

  /// Create a copy of AdListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StoreMiniCopyWith<$Res>? get store {
    if (_value.store == null) {
      return null;
    }

    return $StoreMiniCopyWith<$Res>(_value.store!, (value) {
      return _then(_value.copyWith(store: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AdListItemImplCopyWith<$Res>
    implements $AdListItemCopyWith<$Res> {
  factory _$$AdListItemImplCopyWith(
    _$AdListItemImpl value,
    $Res Function(_$AdListItemImpl) then,
  ) = __$$AdListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    double price,
    String currency,
    String coverUrl,
    String createdAt,
    CityMini city,
    CategoryMini category,
    StoreMini? store,
    bool isVipActive,
    bool isPremiumActive,
  });

  @override
  $CityMiniCopyWith<$Res> get city;
  @override
  $CategoryMiniCopyWith<$Res> get category;
  @override
  $StoreMiniCopyWith<$Res>? get store;
}

/// @nodoc
class __$$AdListItemImplCopyWithImpl<$Res>
    extends _$AdListItemCopyWithImpl<$Res, _$AdListItemImpl>
    implements _$$AdListItemImplCopyWith<$Res> {
  __$$AdListItemImplCopyWithImpl(
    _$AdListItemImpl _value,
    $Res Function(_$AdListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? price = null,
    Object? currency = null,
    Object? coverUrl = null,
    Object? createdAt = null,
    Object? city = null,
    Object? category = null,
    Object? store = freezed,
    Object? isVipActive = null,
    Object? isPremiumActive = null,
  }) {
    return _then(
      _$AdListItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        coverUrl: null == coverUrl
            ? _value.coverUrl
            : coverUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as CityMini,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as CategoryMini,
        store: freezed == store
            ? _value.store
            : store // ignore: cast_nullable_to_non_nullable
                  as StoreMini?,
        isVipActive: null == isVipActive
            ? _value.isVipActive
            : isVipActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        isPremiumActive: null == isPremiumActive
            ? _value.isPremiumActive
            : isPremiumActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdListItemImpl implements _AdListItem {
  const _$AdListItemImpl({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.coverUrl,
    required this.createdAt,
    required this.city,
    required this.category,
    this.store,
    this.isVipActive = false,
    this.isPremiumActive = false,
  });

  factory _$AdListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdListItemImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final double price;
  @override
  final String currency;
  @override
  final String coverUrl;
  @override
  final String createdAt;
  @override
  final CityMini city;
  @override
  final CategoryMini category;
  @override
  final StoreMini? store;
  @override
  @JsonKey()
  final bool isVipActive;
  @override
  @JsonKey()
  final bool isPremiumActive;

  @override
  String toString() {
    return 'AdListItem(id: $id, title: $title, price: $price, currency: $currency, coverUrl: $coverUrl, createdAt: $createdAt, city: $city, category: $category, store: $store, isVipActive: $isVipActive, isPremiumActive: $isPremiumActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.store, store) || other.store == store) &&
            (identical(other.isVipActive, isVipActive) ||
                other.isVipActive == isVipActive) &&
            (identical(other.isPremiumActive, isPremiumActive) ||
                other.isPremiumActive == isPremiumActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    price,
    currency,
    coverUrl,
    createdAt,
    city,
    category,
    store,
    isVipActive,
    isPremiumActive,
  );

  /// Create a copy of AdListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdListItemImplCopyWith<_$AdListItemImpl> get copyWith =>
      __$$AdListItemImplCopyWithImpl<_$AdListItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdListItemImplToJson(this);
  }
}

abstract class _AdListItem implements AdListItem {
  const factory _AdListItem({
    required final int id,
    required final String title,
    required final double price,
    required final String currency,
    required final String coverUrl,
    required final String createdAt,
    required final CityMini city,
    required final CategoryMini category,
    final StoreMini? store,
    final bool isVipActive,
    final bool isPremiumActive,
  }) = _$AdListItemImpl;

  factory _AdListItem.fromJson(Map<String, dynamic> json) =
      _$AdListItemImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  double get price;
  @override
  String get currency;
  @override
  String get coverUrl;
  @override
  String get createdAt;
  @override
  CityMini get city;
  @override
  CategoryMini get category;
  @override
  StoreMini? get store;
  @override
  bool get isVipActive;
  @override
  bool get isPremiumActive;

  /// Create a copy of AdListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdListItemImplCopyWith<_$AdListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CityMini _$CityMiniFromJson(Map<String, dynamic> json) {
  return _CityMini.fromJson(json);
}

/// @nodoc
mixin _$CityMini {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this CityMini to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CityMini
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CityMiniCopyWith<CityMini> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CityMiniCopyWith<$Res> {
  factory $CityMiniCopyWith(CityMini value, $Res Function(CityMini) then) =
      _$CityMiniCopyWithImpl<$Res, CityMini>;
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class _$CityMiniCopyWithImpl<$Res, $Val extends CityMini>
    implements $CityMiniCopyWith<$Res> {
  _$CityMiniCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CityMini
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CityMiniImplCopyWith<$Res>
    implements $CityMiniCopyWith<$Res> {
  factory _$$CityMiniImplCopyWith(
    _$CityMiniImpl value,
    $Res Function(_$CityMiniImpl) then,
  ) = __$$CityMiniImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class __$$CityMiniImplCopyWithImpl<$Res>
    extends _$CityMiniCopyWithImpl<$Res, _$CityMiniImpl>
    implements _$$CityMiniImplCopyWith<$Res> {
  __$$CityMiniImplCopyWithImpl(
    _$CityMiniImpl _value,
    $Res Function(_$CityMiniImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CityMini
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _$CityMiniImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CityMiniImpl implements _CityMini {
  const _$CityMiniImpl({required this.id, required this.name});

  factory _$CityMiniImpl.fromJson(Map<String, dynamic> json) =>
      _$$CityMiniImplFromJson(json);

  @override
  final int id;
  @override
  final String name;

  @override
  String toString() {
    return 'CityMini(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CityMiniImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of CityMini
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CityMiniImplCopyWith<_$CityMiniImpl> get copyWith =>
      __$$CityMiniImplCopyWithImpl<_$CityMiniImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CityMiniImplToJson(this);
  }
}

abstract class _CityMini implements CityMini {
  const factory _CityMini({required final int id, required final String name}) =
      _$CityMiniImpl;

  factory _CityMini.fromJson(Map<String, dynamic> json) =
      _$CityMiniImpl.fromJson;

  @override
  int get id;
  @override
  String get name;

  /// Create a copy of CityMini
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CityMiniImplCopyWith<_$CityMiniImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategoryMini _$CategoryMiniFromJson(Map<String, dynamic> json) {
  return _CategoryMini.fromJson(json);
}

/// @nodoc
mixin _$CategoryMini {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;

  /// Serializes this CategoryMini to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryMini
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryMiniCopyWith<CategoryMini> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryMiniCopyWith<$Res> {
  factory $CategoryMiniCopyWith(
    CategoryMini value,
    $Res Function(CategoryMini) then,
  ) = _$CategoryMiniCopyWithImpl<$Res, CategoryMini>;
  @useResult
  $Res call({int id, String name, String slug});
}

/// @nodoc
class _$CategoryMiniCopyWithImpl<$Res, $Val extends CategoryMini>
    implements $CategoryMiniCopyWith<$Res> {
  _$CategoryMiniCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryMini
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? slug = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategoryMiniImplCopyWith<$Res>
    implements $CategoryMiniCopyWith<$Res> {
  factory _$$CategoryMiniImplCopyWith(
    _$CategoryMiniImpl value,
    $Res Function(_$CategoryMiniImpl) then,
  ) = __$$CategoryMiniImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String slug});
}

/// @nodoc
class __$$CategoryMiniImplCopyWithImpl<$Res>
    extends _$CategoryMiniCopyWithImpl<$Res, _$CategoryMiniImpl>
    implements _$$CategoryMiniImplCopyWith<$Res> {
  __$$CategoryMiniImplCopyWithImpl(
    _$CategoryMiniImpl _value,
    $Res Function(_$CategoryMiniImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CategoryMini
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? slug = null}) {
    return _then(
      _$CategoryMiniImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryMiniImpl implements _CategoryMini {
  const _$CategoryMiniImpl({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory _$CategoryMiniImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryMiniImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String slug;

  @override
  String toString() {
    return 'CategoryMini(id: $id, name: $name, slug: $slug)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryMiniImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, slug);

  /// Create a copy of CategoryMini
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryMiniImplCopyWith<_$CategoryMiniImpl> get copyWith =>
      __$$CategoryMiniImplCopyWithImpl<_$CategoryMiniImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryMiniImplToJson(this);
  }
}

abstract class _CategoryMini implements CategoryMini {
  const factory _CategoryMini({
    required final int id,
    required final String name,
    required final String slug,
  }) = _$CategoryMiniImpl;

  factory _CategoryMini.fromJson(Map<String, dynamic> json) =
      _$CategoryMiniImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get slug;

  /// Create a copy of CategoryMini
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryMiniImplCopyWith<_$CategoryMiniImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StoreMini _$StoreMiniFromJson(Map<String, dynamic> json) {
  return _StoreMini.fromJson(json);
}

/// @nodoc
mixin _$StoreMini {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;

  /// Serializes this StoreMini to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoreMini
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoreMiniCopyWith<StoreMini> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreMiniCopyWith<$Res> {
  factory $StoreMiniCopyWith(StoreMini value, $Res Function(StoreMini) then) =
      _$StoreMiniCopyWithImpl<$Res, StoreMini>;
  @useResult
  $Res call({int id, String name, String slug});
}

/// @nodoc
class _$StoreMiniCopyWithImpl<$Res, $Val extends StoreMini>
    implements $StoreMiniCopyWith<$Res> {
  _$StoreMiniCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoreMini
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? slug = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StoreMiniImplCopyWith<$Res>
    implements $StoreMiniCopyWith<$Res> {
  factory _$$StoreMiniImplCopyWith(
    _$StoreMiniImpl value,
    $Res Function(_$StoreMiniImpl) then,
  ) = __$$StoreMiniImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String slug});
}

/// @nodoc
class __$$StoreMiniImplCopyWithImpl<$Res>
    extends _$StoreMiniCopyWithImpl<$Res, _$StoreMiniImpl>
    implements _$$StoreMiniImplCopyWith<$Res> {
  __$$StoreMiniImplCopyWithImpl(
    _$StoreMiniImpl _value,
    $Res Function(_$StoreMiniImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StoreMini
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? slug = null}) {
    return _then(
      _$StoreMiniImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StoreMiniImpl implements _StoreMini {
  const _$StoreMiniImpl({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory _$StoreMiniImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoreMiniImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String slug;

  @override
  String toString() {
    return 'StoreMini(id: $id, name: $name, slug: $slug)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreMiniImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, slug);

  /// Create a copy of StoreMini
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreMiniImplCopyWith<_$StoreMiniImpl> get copyWith =>
      __$$StoreMiniImplCopyWithImpl<_$StoreMiniImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoreMiniImplToJson(this);
  }
}

abstract class _StoreMini implements StoreMini {
  const factory _StoreMini({
    required final int id,
    required final String name,
    required final String slug,
  }) = _$StoreMiniImpl;

  factory _StoreMini.fromJson(Map<String, dynamic> json) =
      _$StoreMiniImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get slug;

  /// Create a copy of StoreMini
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoreMiniImplCopyWith<_$StoreMiniImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
