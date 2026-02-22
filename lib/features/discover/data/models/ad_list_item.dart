import '../../../../core/models/publisher.dart';

class AdListItem {
  final int id;
  final String title;
  final double price;
  final String priceStr;
  final String currency;

  final String coverUrl;

  final String cityName;
  final String userName;

  /// publisher metadata (type, id, avatar etc) if available
  final Publisher? publisher;

  final String dateStr;

  final bool isVipActive;
  final bool isPremiumActive;

  AdListItem({
    required this.id,
    required this.title,
    required this.price,
    required this.priceStr,
    required this.currency,
    required this.coverUrl,
    required this.cityName,
    required this.userName,
    this.publisher,
    required this.dateStr,
    required this.isVipActive,
    required this.isPremiumActive,
  });

  factory AdListItem.fromJson(Map<String, dynamic> json) {
    final city = (json['city'] is Map) ? (json['city']['name'] ?? '') : (json['city'] ?? '');
    final store = (json['store'] is Map) ? json['store'] : null;

    // user adı: store varsa store.name, yoxsa "İstifadəçi {id}"
    final userName =
        (store != null && store['name'] != null) ? store['name'].toString() : 'İstifadəçi ${(json['user_id'] ?? '').toString()}';

    Publisher? publisher;
    if (json['publisher'] is Map) {
      publisher = Publisher.fromJson(Map<String, dynamic>.from(json['publisher']));
    } else if (store != null) {
      // fallback: create a simple publisher for store
      publisher = Publisher(
        type: 'store',
        id: (store['id'] is num) ? (store['id'] as num).toInt() : int.tryParse('${store['id']}') ?? 0,
        name: store['name']?.toString() ?? '',
        avatarUrl: store['avatar_url']?.toString(),
        slug: store['slug']?.toString(),
      );
    }

    final cover = (json['cover_url'] ?? json['coverUrl'] ?? '').toString();

    final pRaw = json['price'];
    final price = pRaw is num ? pRaw.toDouble() : double.tryParse('$pRaw') ?? 0;

    return AdListItem(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      price: price,
      priceStr: (json['price_str'] ?? '').toString(),
      currency: (json['currency'] ?? 'AZN').toString(),
      coverUrl: cover,
      cityName: city.toString(),
      userName: userName,
      publisher: publisher,
      dateStr: (json['created_at'] ?? '').toString(),
      isVipActive: json['is_vip_active'] == true,
      isPremiumActive: json['is_premium_active'] == true,
    );
  }
}