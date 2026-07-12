class ManualProductCreateModel {
  final String? barcode;
  final String name;
  final String? brand;
  final List<String> tags;
  final String? imageUrl;
  final String? quantity;

  const ManualProductCreateModel({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.tags,
    required this.imageUrl,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'tags': tags,
      'image_url': imageUrl,
      'quantity': quantity,
    };
  }
}
