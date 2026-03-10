class DiscoverCategoryItem {
  final int id;
  final String name;
  final String slug;
  final String? imageUrl;
  final int? parentId;

  const DiscoverCategoryItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
    required this.parentId,
  });

  factory DiscoverCategoryItem.fromJson(Map<String, dynamic> json) {
    return DiscoverCategoryItem(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      imageUrl: json['image_url']?.toString(),
      parentId: json['parent_id'] is num ? (json['parent_id'] as num).toInt() : null,
    );
  }
}