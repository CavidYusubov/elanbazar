import '../../../../core/models/publisher.dart';

class ReelAd {
  final int id;
  final String title;
  final double price;
  final String currency;
  final String coverUrl;
  final String city;
  final String category;

  /// information about who published this ad; may be a user or a store
  final Publisher? publisher;

  final int likeCount;
  final int commentCount;

  ReelAd({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.coverUrl,
    required this.city,
    required this.category,
    this.publisher,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  factory ReelAd.fromJson(Map<String, dynamic> json) {
    final cover = (json['coverUrl'] ??
            json['cover_url'] ??
            json['cover']?['url'] ??
            json['cover']?['full_url'] ??
            '')
        .toString();

    final cityName =
        (json['city'] is Map ? (json['city']['name'] ?? '') : json['city'])
                ?.toString() ??
            '';

    final catName =
        (json['category'] is Map
                    ? (json['category']['name'] ?? '')
                    : json['category'])
                ?.toString() ??
            '';

    return ReelAd(
      id: _toInt(json['id']),
      title: (json['title'] ?? '').toString(),
      price: _toDouble(json['price']),
      currency: (json['currency'] ?? 'AZN').toString(),
      coverUrl: cover,
      city: cityName,
      category: catName,
      publisher: (json['publisher'] is Map)
          ? Publisher.fromJson(Map<String, dynamic>.from(json['publisher']))
          : null,
      likeCount: _toInt(json['like_count']),
      commentCount: _toInt(json['comment_count']),
    );
  }
}