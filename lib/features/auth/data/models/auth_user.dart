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
    return AuthUser(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString().trim(),
      email: _nullableString(json['email']),
      phone: _nullableString(json['phone']),
      photoUrl: _nullableString(
        json['photo_url'] ??
            json['avatar_url'] ??
            json['photo'] ??
            json['image_url'],
      ),
      store: json['store'] is Map<String, dynamic>
          ? AuthStoreMini.fromJson(json['store'] as Map<String, dynamic>)
          : (json['store'] is Map
              ? AuthStoreMini.fromJson(
                  Map<String, dynamic>.from(json['store'] as Map),
                )
              : null),
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
    if (name.trim().isNotEmpty) return name.trim();
    return 'İstifadəçi';
  }

  String? get avatarUrl {
    if (photoUrl == null || photoUrl!.trim().isEmpty) return null;
    return photoUrl!.trim();
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

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? 0}') ?? 0;
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

  const AuthStoreMini({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory AuthStoreMini.fromJson(Map<String, dynamic> json) {
    return AuthStoreMini(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString().trim(),
      slug: (json['slug'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? 0}') ?? 0;
  }
}