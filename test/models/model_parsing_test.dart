import 'package:elanbazar/features/ads_detail/models/ad_detail.dart';
import 'package:elanbazar/features/discover/data/models/ad_list_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdListItem.fromJson', () {
    test('maps priceStr and store publisher fallback', () {
      final item = AdListItem.fromJson({
        'id': 10,
        'title': 'Test elan',
        'price': '199.9',
        'price_str': '199.9',
        'currency': 'AZN',
        'cover_url': 'https://cdn.test/image.jpg',
        'city': {'name': 'Baku'},
        'store': {
          'id': 99,
          'name': 'Store A',
          'slug': 'store-a',
          'avatar_url': 'https://cdn.test/store.jpg',
        },
        'created_at': '2026-03-09T12:00:00Z',
        'is_vip_active': true,
        'is_premium_active': false,
      });

      expect(item.priceStr, '199.9');
      expect(item.userName, 'Store A');
      expect(item.publisher?.type, 'store');
      expect(item.publisher?.slug, 'store-a');
      expect(item.cityName, 'Baku');
    });
  });

  group('AdDetail', () {
    test('galleryUrls keeps cover first and removes duplicates', () {
      final ad = AdDetail.fromJson({
        'id': 1,
        'title': 'Ad',
        'currency': 'AZN',
        'cover_url': 'https://cdn.test/cover.jpg',
        'images': [
          {'id': 1, 'is_cover': false, 'position': 1, 'url': 'https://cdn.test/cover.jpg'},
          {'id': 2, 'is_cover': false, 'position': 2, 'url': 'https://cdn.test/2.jpg'},
        ],
        'attributes': [],
        'views_count': 0,
      });

      expect(ad.galleryUrls, ['https://cdn.test/cover.jpg', 'https://cdn.test/2.jpg']);
    });

    test('bool and numeric fields are parsed from mixed types', () {
      final ad = AdDetail.fromJson({
        'id': '12',
        'title': 'Ad',
        'price': '450',
        'currency': 'AZN',
        'is_vip_active': 1,
        'is_premium_active': 'true',
        'images': [],
        'attributes': [],
        'views_count': '34',
      });

      expect(ad.id, 12);
      expect(ad.price, 450);
      expect(ad.isVipActive, isTrue);
      expect(ad.isPremiumActive, isTrue);
      expect(ad.viewsCount, 34);
    });
  });
}
