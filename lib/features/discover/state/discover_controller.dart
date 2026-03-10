import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/discover_repo.dart';
import '../data/models/ad_list_item.dart';
import '../data/models/discover_category_item.dart';

final discoverRepoProvider = Provider<DiscoverRepo>((ref) {
  return DiscoverRepo();
});

final discoverControllerProvider =
    StateNotifierProvider<DiscoverController, DiscoverState>((ref) {
  return DiscoverController(ref.read(discoverRepoProvider));
});

class DiscoverState {
  final bool loading;
  final bool loadingMore;

  final List<AdListItem> premiumItems;
  final List<AdListItem> vipItems;
  final List<AdListItem> latestItems;
  final List<AdListItem> listingItems;

  final DiscoverCategoryItem? selectedCategory;
  final DiscoverCategoryItem? categoryRailRoot;
  final List<DiscoverCategoryItem> categoryRailItems;

  final List<DiscoverCityItem> cities;

  final String listingTitle;
  final String scope;
  final String? nextCursor;
  final bool hasMore;
  final String? error;

  final String query;
  final int? cityId;
  final double? minPrice;
  final double? maxPrice;
  final String sort;

  const DiscoverState({
    required this.loading,
    required this.loadingMore,
    required this.premiumItems,
    required this.vipItems,
    required this.latestItems,
    required this.listingItems,
    required this.selectedCategory,
    required this.categoryRailRoot,
    required this.categoryRailItems,
    required this.cities,
    required this.listingTitle,
    required this.scope,
    required this.nextCursor,
    required this.hasMore,
    required this.error,
    required this.query,
    required this.cityId,
    required this.minPrice,
    required this.maxPrice,
    required this.sort,
  });

  factory DiscoverState.initial() {
    return const DiscoverState(
      loading: true,
      loadingMore: false,
      premiumItems: [],
      vipItems: [],
      latestItems: [],
      listingItems: [],
      selectedCategory: null,
      categoryRailRoot: null,
      categoryRailItems: [],
      cities: [],
      listingTitle: '',
      scope: 'all',
      nextCursor: null,
      hasMore: false,
      error: null,
      query: '',
      cityId: null,
      minPrice: null,
      maxPrice: null,
      sort: 'date_desc',
    );
  }

  bool get isListingMode => selectedCategory != null || scope != 'all' || hasActiveFilters;

  bool get hasActiveFilters =>
      query.trim().isNotEmpty ||
      cityId != null ||
      minPrice != null ||
      maxPrice != null ||
      sort != 'date_desc';

  DiscoverCityItem? get selectedCity {
    if (cityId == null) return null;
    for (final c in cities) {
      if (c.id == cityId) return c;
    }
    return null;
  }

  DiscoverState copyWith({
    bool? loading,
    bool? loadingMore,
    List<AdListItem>? premiumItems,
    List<AdListItem>? vipItems,
    List<AdListItem>? latestItems,
    List<AdListItem>? listingItems,
    Object? selectedCategory = _sentinel,
    Object? categoryRailRoot = _sentinel,
    List<DiscoverCategoryItem>? categoryRailItems,
    List<DiscoverCityItem>? cities,
    String? listingTitle,
    String? scope,
    Object? nextCursor = _sentinel,
    bool? hasMore,
    Object? error = _sentinel,
    String? query,
    Object? cityId = _sentinel,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    String? sort,
  }) {
    return DiscoverState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      premiumItems: premiumItems ?? this.premiumItems,
      vipItems: vipItems ?? this.vipItems,
      latestItems: latestItems ?? this.latestItems,
      listingItems: listingItems ?? this.listingItems,
      selectedCategory: identical(selectedCategory, _sentinel)
          ? this.selectedCategory
          : selectedCategory as DiscoverCategoryItem?,
      categoryRailRoot: identical(categoryRailRoot, _sentinel)
          ? this.categoryRailRoot
          : categoryRailRoot as DiscoverCategoryItem?,
      categoryRailItems: categoryRailItems ?? this.categoryRailItems,
      cities: cities ?? this.cities,
      listingTitle: listingTitle ?? this.listingTitle,
      scope: scope ?? this.scope,
      nextCursor:
          identical(nextCursor, _sentinel) ? this.nextCursor : nextCursor as String?,
      hasMore: hasMore ?? this.hasMore,
      error: identical(error, _sentinel) ? this.error : error as String?,
      query: query ?? this.query,
      cityId: identical(cityId, _sentinel) ? this.cityId : cityId as int?,
      minPrice: identical(minPrice, _sentinel) ? this.minPrice : minPrice as double?,
      maxPrice: identical(maxPrice, _sentinel) ? this.maxPrice : maxPrice as double?,
      sort: sort ?? this.sort,
    );
  }
}

const _sentinel = Object();

class DiscoverController extends StateNotifier<DiscoverState> {
  DiscoverController(this._repo) : super(DiscoverState.initial()) {
    loadHome();
  }

  final DiscoverRepo _repo;
  bool _busy = false;

  Future<void> loadHome() async {
    if (_busy) return;
    _busy = true;

    state = state.copyWith(
      loading: true,
      loadingMore: false,
      listingItems: [],
      selectedCategory: null,
      categoryRailRoot: null,
      categoryRailItems: [],
      listingTitle: '',
      scope: 'all',
      nextCursor: null,
      hasMore: false,
      error: null,
    );

    try {
      final cities = await _safeLoadCities();

      final premiumRes = await _repo.fetchAds(
        scope: 'premium',
        perPage: 4,
      );
      final vipRes = await _repo.fetchAds(
        scope: 'vip',
        perPage: 4,
      );
      final latestRes = await _repo.fetchAds(
        scope: 'latest',
        perPage: 4,
      );
      final allRes = await _repo.fetchAds(
        scope: 'all',
        perPage: 1,
      );

      state = state.copyWith(
        loading: false,
        loadingMore: false,
        premiumItems: premiumRes.items,
        vipItems: vipRes.items,
        latestItems: latestRes.items,
        listingItems: [],
        selectedCategory: null,
        categoryRailRoot: allRes.categoryRailRoot,
        categoryRailItems: allRes.categoryRailItems,
        cities: cities,
        listingTitle: '',
        scope: 'all',
        nextCursor: null,
        hasMore: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        loadingMore: false,
        premiumItems: const [],
        vipItems: const [],
        latestItems: const [],
        listingItems: const [],
        selectedCategory: null,
        categoryRailRoot: null,
        categoryRailItems: const [],
        listingTitle: '',
        scope: 'all',
        nextCursor: null,
        hasMore: false,
        error: e.toString(),
      );
    } finally {
      _busy = false;
    }
  }

  Future<List<DiscoverCityItem>> _safeLoadCities() async {
    try {
      return await _repo.fetchCities();
    } catch (_) {
      return state.cities;
    }
  }

  Future<void> refresh() async {
    if (state.isListingMode) {
      await _reloadListing();
    } else {
      await loadHome();
    }
  }

  Future<void> backToHome() async {
    await loadHome();
  }

  void setQuery(String v) {
    state = state.copyWith(query: v);
  }

  void setCity(int? cityId) {
    state = state.copyWith(cityId: cityId);
  }

  void setPriceRange({
    double? minPrice,
    double? maxPrice,
  }) {
    state = state.copyWith(
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  void setSort(String sort) {
    state = state.copyWith(sort: sort);
  }

  Future<void> applyFilters() async {
    await _openListing(
      scope: state.scope,
      category: state.selectedCategory,
      title: _resolveListingTitle(),
    );
  }

  Future<void> clearFilters() async {
    state = state.copyWith(
      query: '',
      cityId: null,
      minPrice: null,
      maxPrice: null,
      sort: 'date_desc',
    );

    if (state.selectedCategory != null || state.scope != 'all') {
      await _openListing(
        scope: state.scope,
        category: state.selectedCategory,
        title: _resolveListingTitle(),
      );
    } else {
      await loadHome();
    }
  }

  Future<void> removeQuery() async {
    state = state.copyWith(query: '');
    await _afterFilterChipRemoved();
  }

  Future<void> removeCity() async {
    state = state.copyWith(cityId: null);
    await _afterFilterChipRemoved();
  }

  Future<void> removeMinPrice() async {
    state = state.copyWith(minPrice: null);
    await _afterFilterChipRemoved();
  }

  Future<void> removeMaxPrice() async {
    state = state.copyWith(maxPrice: null);
    await _afterFilterChipRemoved();
  }

  Future<void> resetSort() async {
    state = state.copyWith(sort: 'date_desc');
    await _afterFilterChipRemoved();
  }

  Future<void> _afterFilterChipRemoved() async {
    if (state.selectedCategory != null || state.scope != 'all' || state.hasActiveFilters) {
      await _openListing(
        scope: state.scope,
        category: state.selectedCategory,
        title: _resolveListingTitle(),
      );
    } else {
      await loadHome();
    }
  }

  Future<void> openScope(
    String scope, {
    String? title,
  }) async {
    await _openListing(
      scope: scope,
      category: null,
      title: title ?? _titleFromScope(scope),
    );
  }

  Future<void> openCategory(DiscoverCategoryItem category) async {
    await _openListing(
      scope: 'all',
      category: category,
      title: category.name,
    );
  }

  Future<void> _openListing({
    required String scope,
    required DiscoverCategoryItem? category,
    required String title,
  }) async {
    if (_busy) return;
    _busy = true;

    state = state.copyWith(
      loading: true,
      loadingMore: false,
      listingItems: [],
      selectedCategory: category,
      listingTitle: title,
      scope: scope,
      nextCursor: null,
      hasMore: true,
      error: null,
    );

    try {
      final r = await _repo.fetchAds(
        scope: scope,
        categoryId: category?.id,
        cursor: null,
        perPage: 20,
        q: state.query,
        cityId: state.cityId,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sort: state.sort,
      );

      state = state.copyWith(
        loading: false,
        loadingMore: false,
        listingItems: r.items,
        selectedCategory: r.selectedCategory ?? category,
        categoryRailRoot: r.categoryRailRoot,
        categoryRailItems: r.categoryRailItems,
        listingTitle: r.selectedCategory?.name ?? title,
        scope: scope,
        nextCursor: r.nextCursor,
        hasMore: r.hasMore,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        loadingMore: false,
        listingItems: const [],
        selectedCategory: category,
        categoryRailRoot: null,
        categoryRailItems: const [],
        listingTitle: title,
        scope: scope,
        nextCursor: null,
        hasMore: false,
        error: e.toString(),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> loadMore() async {
    if (_busy) return;
    if (!state.isListingMode) return;
    if (!state.hasMore) return;
    if (state.nextCursor == null || state.nextCursor!.isEmpty) return;

    _busy = true;

    state = state.copyWith(
      loadingMore: true,
      error: null,
    );

    try {
      final r = await _repo.fetchAds(
        scope: state.scope,
        categoryId: state.selectedCategory?.id,
        cursor: state.nextCursor,
        perPage: 20,
        q: state.query,
        cityId: state.cityId,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sort: state.sort,
      );

      state = state.copyWith(
        loading: false,
        loadingMore: false,
        listingItems: [...state.listingItems, ...r.items],
        selectedCategory: r.selectedCategory ?? state.selectedCategory,
        categoryRailRoot: r.categoryRailRoot ?? state.categoryRailRoot,
        categoryRailItems:
            r.categoryRailItems.isNotEmpty ? r.categoryRailItems : state.categoryRailItems,
        nextCursor: r.nextCursor,
        hasMore: r.hasMore,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        loadingMore: false,
        error: e.toString(),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> _reloadListing() async {
    if (_busy) return;
    _busy = true;

    state = state.copyWith(
      loading: true,
      loadingMore: false,
      listingItems: [],
      nextCursor: null,
      hasMore: true,
      error: null,
    );

    try {
      final r = await _repo.fetchAds(
        scope: state.scope,
        categoryId: state.selectedCategory?.id,
        cursor: null,
        perPage: 20,
        q: state.query,
        cityId: state.cityId,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sort: state.sort,
      );

      state = state.copyWith(
        loading: false,
        loadingMore: false,
        listingItems: r.items,
        selectedCategory: r.selectedCategory ?? state.selectedCategory,
        categoryRailRoot: r.categoryRailRoot,
        categoryRailItems: r.categoryRailItems,
        nextCursor: r.nextCursor,
        hasMore: r.hasMore,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        loadingMore: false,
        listingItems: const [],
        nextCursor: null,
        hasMore: false,
        error: e.toString(),
      );
    } finally {
      _busy = false;
    }
  }

  String _titleFromScope(String scope) {
    switch (scope) {
      case 'premium':
        return 'Premium Elanlar';
      case 'vip':
        return 'VIP Elanlar';
      case 'latest':
        return 'Son elanlar';
      default:
        return 'Elanlar';
    }
  }

  String _resolveListingTitle() {
    if (state.selectedCategory != null) return state.selectedCategory!.name;
    if (state.scope != 'all') return _titleFromScope(state.scope);
    return 'Nəticələr';
  }
}