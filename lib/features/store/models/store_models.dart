class StoreCity {
  final int id;
  final String name;

  const StoreCity({
    required this.id,
    required this.name,
  });

  factory StoreCity.fromJson(Map<String, dynamic> json) {
    return StoreCity(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class StoreWorkHours {
  final String? from;
  final String? to;

  const StoreWorkHours({
    this.from,
    this.to,
  });

  factory StoreWorkHours.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StoreWorkHours();
    return StoreWorkHours(
      from: json['from']?.toString(),
      to: json['to']?.toString(),
    );
  }
}

class StoreDetail {
  final int id;
  final int userId;
  final String name;
  final String slug;
  final String status;
  final String statusLabel;
  final String? phone;
  final String? phone2;
  final String? phone3;
  final StoreCity? city;
  final String? address;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final StoreWorkHours workHours;
  final bool isVerified;
  final bool isTop;
  final double rating;
  final int adsCount;

  const StoreDetail({
    required this.id,
    required this.userId,
    required this.name,
    required this.slug,
    required this.status,
    required this.statusLabel,
    required this.phone,
    required this.phone2,
    required this.phone3,
    required this.city,
    required this.address,
    required this.description,
    required this.logoUrl,
    required this.coverUrl,
    required this.workHours,
    required this.isVerified,
    required this.isTop,
    required this.rating,
    required this.adsCount,
  });

  factory StoreDetail.fromJson(Map<String, dynamic> json) {
    return StoreDetail(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      statusLabel: (json['status_label'] ?? '').toString(),
      phone: json['phone']?.toString(),
      phone2: json['phone2']?.toString(),
      phone3: json['phone3']?.toString(),
      city: json['city'] is Map<String, dynamic>
          ? StoreCity.fromJson(json['city'] as Map<String, dynamic>)
          : null,
      address: json['address']?.toString(),
      description: json['description']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      coverUrl: json['cover_url']?.toString(),
      workHours: StoreWorkHours.fromJson(
        json['work_hours'] is Map<String, dynamic>
            ? json['work_hours'] as Map<String, dynamic>
            : null,
      ),
      isVerified: json['is_verified'] == true,
      isTop: json['is_top'] == true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      adsCount: (json['ads_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class StoreMeta {
  final List<StoreCity> cities;

  const StoreMeta({
    required this.cities,
  });

  factory StoreMeta.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final citiesRaw = (data['cities'] as List?) ?? const [];

    return StoreMeta(
      cities: citiesRaw
          .whereType<Map<String, dynamic>>()
          .map(StoreCity.fromJson)
          .toList(),
    );
  }
}

class StoreStatusResponse {
  final bool hasStore;
  final StoreDetail? store;

  const StoreStatusResponse({
    required this.hasStore,
    required this.store,
  });

  factory StoreStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return StoreStatusResponse(
      hasStore: data['has_store'] == true,
      store: data['store'] is Map<String, dynamic>
          ? StoreDetail.fromJson(data['store'] as Map<String, dynamic>)
          : null,
    );
  }
}

class StoreCreatePayload {
  final String name;
  final int? cityId;
  final String? addressShort;
  final String? address;
  final String? workHoursFrom;
  final String? workHoursTo;
  final String phone;
  final String? phone2;
  final String? phone3;
  final String? description;
  final String? logoPath;
  final String? coverPath;

  const StoreCreatePayload({
    required this.name,
    required this.phone,
    this.cityId,
    this.addressShort,
    this.address,
    this.workHoursFrom,
    this.workHoursTo,
    this.phone2,
    this.phone3,
    this.description,
    this.logoPath,
    this.coverPath,
  });
}

class StoreGalleryItem {
  final int id;
  final String url;
  final int position;

  const StoreGalleryItem({
    required this.id,
    required this.url,
    required this.position,
  });

  factory StoreGalleryItem.fromJson(Map<String, dynamic> json) {
    return StoreGalleryItem(
      id: (json['id'] as num).toInt(),
      url: (json['url'] ?? '').toString(),
      position: (json['position'] as num?)?.toInt() ?? 0,
    );
  }
}

class StoreDashboardMessages {
  final String? pending;
  final String? rejected;

  const StoreDashboardMessages({
    this.pending,
    this.rejected,
  });

  factory StoreDashboardMessages.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const StoreDashboardMessages();
    return StoreDashboardMessages(
      pending: json['pending']?.toString(),
      rejected: json['rejected']?.toString(),
    );
  }
}

class StoreDashboard {
  final int id;
  final int userId;
  final String name;
  final String slug;
  final String status;
  final String statusLabel;
  final String statusUi;
  final String? phone;
  final String? phone2;
  final String? phone3;
  final StoreCity? city;
  final String? address;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final StoreWorkHours workHours;
  final bool isVerified;
  final bool isTop;
  final double rating;
  final int adsCount;
  final List<StoreGalleryItem> gallery;
  final StoreDashboardMessages messages;

  const StoreDashboard({
    required this.id,
    required this.userId,
    required this.name,
    required this.slug,
    required this.status,
    required this.statusLabel,
    required this.statusUi,
    required this.phone,
    required this.phone2,
    required this.phone3,
    required this.city,
    required this.address,
    required this.description,
    required this.logoUrl,
    required this.coverUrl,
    required this.workHours,
    required this.isVerified,
    required this.isTop,
    required this.rating,
    required this.adsCount,
    required this.gallery,
    required this.messages,
  });

  factory StoreDashboard.fromJson(Map<String, dynamic> json) {
    final galleryRaw = (json['gallery'] as List?) ?? const [];

    return StoreDashboard(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      statusLabel: (json['status_label'] ?? '').toString(),
      statusUi: (json['status_ui'] ?? 'waiting').toString(),
      phone: json['phone']?.toString(),
      phone2: json['phone2']?.toString(),
      phone3: json['phone3']?.toString(),
      city: json['city'] is Map<String, dynamic>
          ? StoreCity.fromJson(json['city'] as Map<String, dynamic>)
          : (json['city'] is Map
              ? StoreCity.fromJson(Map<String, dynamic>.from(json['city'] as Map))
              : null),
      address: json['address']?.toString(),
      description: json['description']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      coverUrl: json['cover_url']?.toString(),
      workHours: StoreWorkHours.fromJson(
        json['work_hours'] is Map<String, dynamic>
            ? json['work_hours'] as Map<String, dynamic>
            : (json['work_hours'] is Map
                ? Map<String, dynamic>.from(json['work_hours'] as Map)
                : null),
      ),
      isVerified: json['is_verified'] == true,
      isTop: json['is_top'] == true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      adsCount: (json['ads_count'] as num?)?.toInt() ?? 0,
      gallery: galleryRaw
          .map((e) => StoreGalleryItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      messages: StoreDashboardMessages.fromJson(
        json['messages'] is Map<String, dynamic>
            ? json['messages'] as Map<String, dynamic>
            : (json['messages'] is Map
                ? Map<String, dynamic>.from(json['messages'] as Map)
                : null),
      ),
    );
  }
}

class StoreEditMeta {
  final List<StoreCity> cities;
  final StoreDashboard store;

  const StoreEditMeta({
    required this.cities,
    required this.store,
  });

  factory StoreEditMeta.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final citiesRaw = (data['cities'] as List?) ?? const [];
    final storeRaw = data['store'] as Map<String, dynamic>? ?? {};

    return StoreEditMeta(
      cities: citiesRaw
          .map((e) => StoreCity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      store: StoreDashboard.fromJson(storeRaw),
    );
  }
}

class StoreUpdatePayload {
  final String name;
  final int? cityId;
  final String? addressShort;
  final String? address;
  final String phone;
  final String? workHoursFrom;
  final String? workHoursTo;
  final String? description;
  final String? logoPath;
  final String? coverPath;
  final List<String> galleryPaths;

  const StoreUpdatePayload({
    required this.name,
    required this.phone,
    this.cityId,
    this.addressShort,
    this.address,
    this.workHoursFrom,
    this.workHoursTo,
    this.description,
    this.logoPath,
    this.coverPath,
    this.galleryPaths = const [],
  });
}