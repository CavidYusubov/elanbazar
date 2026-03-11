class AdCreateCategory {
  final int id;
  final int? parentId;
  final String name;
  final String? imageUrl;
  final String? iconUrl;

  const AdCreateCategory({
    required this.id,
    this.parentId,
    required this.name,
    this.imageUrl,
    this.iconUrl,
  });

  factory AdCreateCategory.fromJson(Map<String, dynamic> json) {
    return AdCreateCategory(
      id: (json['id'] as num).toInt(),
      parentId: json['parent_id'] == null ? null : (json['parent_id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['image'])?.toString(),
      iconUrl: json['icon_url']?.toString(),
    );
  }
}