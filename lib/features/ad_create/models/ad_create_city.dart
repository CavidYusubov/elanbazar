class AdCreateCity {
  final int id;
  final String name;

  const AdCreateCity({
    required this.id,
    required this.name,
  });

  factory AdCreateCity.fromJson(Map<String, dynamic> json) {
    return AdCreateCity(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AdCreateCity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}