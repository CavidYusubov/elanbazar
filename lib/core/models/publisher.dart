class Publisher {
  final String type; // "user" or "store"
  final int id;
  final String name;
  final String? avatarUrl;
  final String? slug;

  Publisher({
    required this.type,
    required this.id,
    required this.name,
    this.avatarUrl,
    this.slug,
  });

  factory Publisher.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('Publisher JSON cannot be null');
    }

    return Publisher(
      type: json['type']?.toString() ?? '',
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      slug: json['slug']?.toString(),
    );
  }
}
