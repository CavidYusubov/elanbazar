class AdCreateAttributeOption {
  final String id;
  final String value;
  final String label;

  const AdCreateAttributeOption({
    required this.id,
    required this.value,
    required this.label,
  });

  factory AdCreateAttributeOption.fromJson(Map<String, dynamic> json) {
    return AdCreateAttributeOption(
      id: (json['id'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
    );
  }
}

class AdCreateAttributeDependency {
  final int parentAttributeId;
  final String? parentOptionId;
  final String? parentOptionValue;
  final int sortOrder;

  const AdCreateAttributeDependency({
    required this.parentAttributeId,
    this.parentOptionId,
    this.parentOptionValue,
    required this.sortOrder,
  });

  factory AdCreateAttributeDependency.fromJson(Map<String, dynamic> json) {
    return AdCreateAttributeDependency(
      parentAttributeId: (json['parent_attribute_id'] as num).toInt(),
      parentOptionId: json['parent_option_id']?.toString(),
      parentOptionValue: json['parent_option_value']?.toString(),
      sortOrder: ((json['sort_order'] ?? 0) as num).toInt(),
    );
  }
}

class AdCreateAttribute {
  final int id;
  final String name;
  final String key;
  final String type;
  final String? unit;
  final bool multi;
  final bool required;
  final int position;
  final bool isFilter;
  final bool isRoot;
  final AdCreateAttributeDependency? dependency;
  final List<AdCreateAttributeOption> options;

  const AdCreateAttribute({
    required this.id,
    required this.name,
    required this.key,
    required this.type,
    this.unit,
    required this.multi,
    required this.required,
    required this.position,
    required this.isFilter,
    required this.isRoot,
    this.dependency,
    required this.options,
  });

  factory AdCreateAttribute.fromJson(Map<String, dynamic> json) {
    return AdCreateAttribute(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      key: (json['key'] ?? '').toString(),
      type: (json['type'] ?? 'text').toString(),
      unit: json['unit']?.toString(),
      multi: json['multi'] == true,
      required: json['required'] == true,
      position: ((json['position'] ?? 0) as num).toInt(),
      isFilter: json['is_filter'] == true,
      isRoot: json['is_root'] == true,
      dependency: json['dependency'] is Map
          ? AdCreateAttributeDependency.fromJson(
              Map<String, dynamic>.from(json['dependency']),
            )
          : null,
      options: (json['options'] as List? ?? [])
          .map((e) => AdCreateAttributeOption.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}