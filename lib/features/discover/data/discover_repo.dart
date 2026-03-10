import '../../../core/network/api_client.dart';
import 'models/ad_list_item.dart';
import 'models/discover_category_item.dart';

class DiscoverResponse {
  final List<AdListItem> items;
  final String? nextCursor;
  final bool hasMore;

  final DiscoverCategoryItem? selectedCategory;
  final DiscoverCategoryItem? categoryRailRoot;
  final List<DiscoverCategoryItem> categoryRailItems;

  DiscoverResponse({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
    required this.selectedCategory,
    required this.categoryRailRoot,
    required this.categoryRailItems,
  });
}

class DiscoverCityItem {
  final int id;
  final String name;

  const DiscoverCityItem({
    required this.id,
    required this.name,
  });

  factory DiscoverCityItem.fromJson(Map<String, dynamic> json) {
    return DiscoverCityItem(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class DiscoverRepo {
  Future<DiscoverResponse> fetchAds({
    String scope = 'all',
    int? categoryId,
    String? cursor,
    int perPage = 20,
    String? q,
    int? cityId,
    double? minPrice,
    double? maxPrice,
    String? sort,
  }) async {
    final qp = <String, dynamic>{
      'scope': scope,
      'per_page': perPage,
    };

    if (categoryId != null) qp['category_id'] = categoryId;
    if (cursor != null && cursor.isNotEmpty) qp['cursor'] = cursor;
    if (q != null && q.trim().isNotEmpty) qp['q'] = q.trim();
    if (cityId != null) qp['city_id'] = cityId;
    if (minPrice != null) qp['min_price'] = minPrice;
    if (maxPrice != null) qp['max_price'] = maxPrice;
    if (sort != null && sort.isNotEmpty) qp['sort'] = sort;

    final res = await ApiClient.I.dio.get('/ads', queryParameters: qp);
    final body = res.data;

    if (body is Map && body['ok'] == true) {
      final data = body['data'];
      final meta = body['meta'];

      if (data is Map && data['items'] is List) {
        final list = (data['items'] as List)
            .whereType<Map>()
            .map((e) => AdListItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        DiscoverCategoryItem? selectedCategory;
        DiscoverCategoryItem? categoryRailRoot;
        List<DiscoverCategoryItem> categoryRailItems = [];

        if (data['selected_category'] is Map) {
          selectedCategory = DiscoverCategoryItem.fromJson(
            Map<String, dynamic>.from(data['selected_category']),
          );
        }

        if (data['category_rail'] is Map) {
          final rail = Map<String, dynamic>.from(data['category_rail']);

          if (rail['root'] is Map) {
            categoryRailRoot = DiscoverCategoryItem.fromJson(
              Map<String, dynamic>.from(rail['root']),
            );
          }

          if (rail['items'] is List) {
            categoryRailItems = (rail['items'] as List)
                .whereType<Map>()
                .map((e) => DiscoverCategoryItem.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
        }

        return DiscoverResponse(
          items: list,
          nextCursor: (meta is Map) ? meta['next_cursor']?.toString() : null,
          hasMore: (meta is Map && meta['has_more'] is bool)
              ? meta['has_more'] as bool
              : false,
          selectedCategory: selectedCategory,
          categoryRailRoot: categoryRailRoot,
          categoryRailItems: categoryRailItems,
        );
      }
    }

    throw Exception('Discover ads request failed');
  }

  Future<List<DiscoverCityItem>> fetchCities() async {
    final res = await ApiClient.I.dio.get('/cities');
    final body = res.data;

    if (body is Map && body['ok'] == true) {
      final data = body['data'];
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map>()
            .map((e) => DiscoverCityItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    throw Exception('Cities request failed');
  }
}