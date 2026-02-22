class AdDetail {
  final int id;
  final String title;
  final String? description;

  final double? price;
  final String? priceStr;
  final String currency;

  final bool isVipActive;
  final bool isPremiumActive;

  final AdCity? city;
  final AdUser? user;
  final AdStore? store;

  final String? coverUrl;
  final List<AdImage> images;
  final List<AdAttr> attributes;

  final int viewsCount;
  final String? createdAt;

  const AdDetail({
    required this.id,
    required this.title,
    this.description,
    this.price,
    this.priceStr,
    required this.currency,
    required this.isVipActive,
    required this.isPremiumActive,
    this.city,
    this.user,
    this.store,
    this.coverUrl,
    required this.images,
    required this.attributes,
    required this.viewsCount,
    this.createdAt,
  });

  List<String> get galleryUrls {
    final out = <String>[];
    if ((coverUrl ?? '').trim().isNotEmpty) out.add(coverUrl!.trim());

    // cover təkrar düşməsin
    for (final im in images) {
      final u = im.url.trim();
      if (u.isEmpty) continue;
      if (out.contains(u)) continue;
      out.add(u);
    }
    return out.isEmpty ? [''] : out; // boş qalmasın (PageView error verməsin)
  }

  factory AdDetail.fromJson(Map<String, dynamic> j) {
    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      final s = v.toString();
      return int.tryParse(s) ?? 0;
    }

    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    bool asBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = (v ?? '').toString().toLowerCase();
      return s == '1' || s == 'true' || s == 'yes';
    }

    AdCity? city;
    final cj = j['city'];
    if (cj is Map) city = AdCity.fromJson(Map<String, dynamic>.from(cj));

    AdUser? user;
    final uj = j['user'];
    if (uj is Map) user = AdUser.fromJson(Map<String, dynamic>.from(uj));

    AdStore? store;
    final sj = j['store'];
    if (sj is Map) store = AdStore.fromJson(Map<String, dynamic>.from(sj));

    final images = <AdImage>[];
    final ij = j['images'];
    if (ij is List) {
      for (final x in ij) {
        if (x is Map) images.add(AdImage.fromJson(Map<String, dynamic>.from(x)));
      }
    }

    final attrs = <AdAttr>[];
    final aj = j['attributes'];
    if (aj is List) {
      for (final x in aj) {
        if (x is Map) attrs.add(AdAttr.fromJson(Map<String, dynamic>.from(x)));
      }
    }

    return AdDetail(
      id: asInt(j['id']),
      title: (j['title'] ?? '').toString(),
      description: (j['description'] ?? '').toString().trim().isEmpty
          ? null
          : (j['description'] ?? '').toString(),
      price: asDouble(j['price']),
      priceStr: j['price_str']?.toString(),
      currency: (j['currency'] ?? 'AZN').toString(),
      isVipActive: asBool(j['is_vip_active']),
      isPremiumActive: asBool(j['is_premium_active']),
      city: city,
      user: user,
      store: store,
      coverUrl: j['cover_url']?.toString(),
      images: images,
      attributes: attrs,
      viewsCount: asInt(j['views_count']),
      createdAt: j['created_at']?.toString(),
    );
  }
}

class AdCity {
  final int id;
  final String name;
  const AdCity({required this.id, required this.name});

  factory AdCity.fromJson(Map<String, dynamic> j) => AdCity(
        id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
        name: (j['name'] ?? '').toString(),
      );
}

class AdUser {
  final int id;
  final String name;
  final String? phone;

  const AdUser({required this.id, required this.name, this.phone});

  factory AdUser.fromJson(Map<String, dynamic> j) => AdUser(
        id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
        name: (j['name'] ?? '').toString(),
        phone: j['phone']?.toString(),
      );
}

class AdStore {
  final int id;
  final String name;
  final String slug;
  final String? phone;
  final bool? isOpenNow;

  const AdStore({
    required this.id,
    required this.name,
    required this.slug,
    this.phone,
    this.isOpenNow,
  });

  factory AdStore.fromJson(Map<String, dynamic> j) {
    bool? b(dynamic v) => v is bool ? v : null;
    return AdStore(
      id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
      name: (j['name'] ?? '').toString(),
      slug: (j['slug'] ?? '').toString(),
      phone: j['phone']?.toString(),
      isOpenNow: b(j['is_open_now']),
    );
  }
}

class AdImage {
  final int id;
  final bool isCover;
  final int position;
  final String url;

  const AdImage({
    required this.id,
    required this.isCover,
    required this.position,
    required this.url,
  });

  factory AdImage.fromJson(Map<String, dynamic> j) {
    bool asBool(dynamic v) => v is bool ? v : (v is num ? v != 0 : false);
    int asInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

    return AdImage(
      id: asInt(j['id']),
      isCover: asBool(j['is_cover']),
      position: asInt(j['position']),
      url: (j['url'] ?? '').toString(),
    );
  }
}

class AdAttr {
  final String label;
  final String value;

  const AdAttr({required this.label, required this.value});

  factory AdAttr.fromJson(Map<String, dynamic> j) {
    final attr = j['attribute'];
    final label = (attr is Map ? (attr['name'] ?? '') : '').toString();
    final val = (j['value'] ?? '').toString();
    return AdAttr(label: label, value: val);
  }
}