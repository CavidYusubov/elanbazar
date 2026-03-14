class AuthUser {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final AuthStoreMini? store;

  const AuthUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.store,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final storeJson = _asMap(json['store']);

    return AuthUser(
      id: _toInt(json['id']),
      name: _string(json['name'], fallback: 'İstifadəçi'),
      email: _nullableString(json['email']),
      phone: _nullableString(json['phone']),
      photoUrl: _nullableString(
        json['photo_url'] ??
            json['avatar_url'] ??
            json['photo'] ??
            json['image_url'],
      ),
      store: storeJson != null ? AuthStoreMini.fromJson(storeJson) : null,
    );
  }

  AuthUser copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    AuthStoreMini? store,
    bool clearEmail = false,
    bool clearPhone = false,
    bool clearPhotoUrl = false,
    bool clearStore = false,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: clearEmail ? null : (email ?? this.email),
      phone: clearPhone ? null : (phone ?? this.phone),
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      store: clearStore ? null : (store ?? this.store),
    );
  }

  bool get isStoreOwner => store != null;

  String get displayName {
    final v = name.trim();
    return v.isNotEmpty ? v : 'İstifadəçi';
  }

  String? get avatarUrl {
    final v = photoUrl?.trim();
    if (v == null || v.isEmpty) return null;
    return v;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo_url': photoUrl,
      'store': store?.toJson(),
    };
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? 0}') ?? 0;
  }

  static String _string(dynamic value, {String fallback = ''}) {
    final v = value?.toString().trim();
    if (v == null || v.isEmpty || v.toLowerCase() == 'null') {
      return fallback;
    }
    return v;
  }

  static String? _nullableString(dynamic value) {
    final v = value?.toString().trim();
    if (v == null || v.isEmpty || v.toLowerCase() == 'null') {
      return null;
    }
    return v;
  }
}

class AuthStoreMini {
  final int id;
  final String name;
  final String slug;
  final String? status;

  const AuthStoreMini({
    required this.id,
    required this.name,
    required this.slug,
    this.status,
  });

  factory AuthStoreMini.fromJson(Map<String, dynamic> json) {
    return AuthStoreMini(
      id: _toInt(json['id']),
      name: _string(json['name'], fallback: 'Mağaza'),
      slug: _string(json['slug']),
      status: _nullableString(json['status']),
    );
  }

  AuthStoreMini copyWith({
    int? id,
    String? name,
    String? slug,
    String? status,
    bool clearStatus = false,
  }) {
    return AuthStoreMini(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      status: clearStatus ? null : (status ?? this.status),
    );
  }

  bool get isApprovedOrActive =>
      status == 'approved' || status == 'active';

  bool get isPending => status == 'pending';

  bool get isRejected => status == 'rejected';

  String get statusLabel {
    switch (status) {
      case 'approved':
      case 'active':
        return 'Mağaza aktivdir';
      case 'pending':
        return 'Mağaza təsdiq gözləyir';
      case 'rejected':
        return 'Mağaza rədd edilib';
      default:
        return 'Mağaza';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'status': status,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? 0}') ?? 0;
  }

  static String _string(dynamic value, {String fallback = ''}) {
    final v = value?.toString().trim();
    if (v == null || v.isEmpty || v.toLowerCase() == 'null') {
      return fallback;
    }
    return v;
  }

  static String? _nullableString(dynamic value) {
    final v = value?.toString().trim();
    if (v == null || v.isEmpty || v.toLowerCase() == 'null') {
      return null;
    }
    return v;
  }
}