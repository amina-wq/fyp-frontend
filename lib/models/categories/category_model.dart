class CategoryModel {
  final String id;
  final String key;
  final String name;
  final String? description;
  final String? iconUrl;
  final String? colorHex;
  final bool isActive;
  final bool isDefault;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.colorHex,
    required this.isActive,
    required this.isDefault,
    required this.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      colorHex: json['color_hex'] as String?,
      isActive: json['is_active'] as bool,
      isDefault: json['is_default'] as bool,
      sortOrder: json['sort_order'] as int,
    );
  }
}
