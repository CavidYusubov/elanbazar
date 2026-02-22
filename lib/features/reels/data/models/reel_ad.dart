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

  factory ReelAd.fromJson(Map<String, dynamic> json) {
    final cover = (json['coverUrl'] ??
            json['cover_url'] ??
            json['cover']?['url'] ??
            json['cover']?['full_url'] ??
            '')!
        .toString();

    final cityName =
        (json['city'] is Map ? (json['city']['name'] ?? '') : json['city'])
                ?.toString() ??
            '';
    final catName = (json['category'] is Map
                ? (json['category']['name'] ?? '')
                : json['category'])
            ?.toString() ??
        '';

    final pRaw = json['price'];
    final price =
        pRaw is num ? pRaw.toDouble() : double.tryParse('$pRaw') ?? 0;

    return ReelAd(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      price: price,
      currency: (json['currency'] ?? 'AZN').toString(),
      coverUrl: cover,
      city: cityName,
      category: catName,
      publisher: (json['publisher'] is Map)
          ? Publisher.fromJson(Map<String, dynamic>.from(json['publisher']))
          : null,
      likeCount: (json['like_count'] is num) ? (json['like_count'] as num).toInt() : 0,
      commentCount: (json['comment_count'] is num) ? (json['comment_count'] as num).toInt() : 0,
    );
  }
}