class ProductModel {
  final String id;
  final String? barcode;
  final String name;
  final String? brand;
  final List<String> tags;
  final String? imageUrl;
  final String? quantity;
  final String source;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.barcode,
    required this.name,
    required this.brand,
    required this.tags,
    required this.imageUrl,
    required this.quantity,
    required this.source,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      barcode: json['barcode'] as String?,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
      imageUrl: json['image_url'] as String?,
      quantity: json['quantity'] as String?,
      source: json['source'] as String,
      isVerified: json['is_verified'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
