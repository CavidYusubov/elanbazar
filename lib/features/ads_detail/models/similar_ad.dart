class SimilarAd {
  SimilarAd({
    required this.id,
    required this.title,
    required this.currency,
    required this.coverUrl,
    required this.cityName,
    required this.priceText,
  });

  final int id;
  final String title;
  final String currency;
  final String coverUrl;
  final String cityName;
  final String priceText;

  factory SimilarAd.fromMap(Map<String, dynamic> m) {
    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      final s = v.toString().trim();
      return int.tryParse(s) ?? 0;
    }

    String asStr(dynamic v) => (v ?? '').toString();

    final id = asInt(m['id']);
    final title = asStr(m['title']);
    final currency = (asStr(m['currency']).isEmpty) ? 'AZN' : asStr(m['currency']);

    final coverUrl = asStr(m['cover_url']).isNotEmpty
        ? asStr(m['cover_url'])
        : asStr(m['coverUrl']); // ehtiyat

    final cityName = asStr(m['city_name']).isNotEmpty
        ? asStr(m['city_name'])
        : asStr(m['cityName']); // ehtiyat

    // backend-dən "price_str" gəlsin deyə belə etdim
    final priceText = asStr(m['price_str']).isNotEmpty
        ? asStr(m['price_str'])
        : asStr(m['priceText']);

    return SimilarAd(
      id: id,
      title: title,
      currency: currency,
      coverUrl: coverUrl,
      cityName: cityName,
      priceText: priceText,
    );
  }
}