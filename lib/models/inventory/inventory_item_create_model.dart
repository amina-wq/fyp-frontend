class InventoryItemCreateModel {
  final String? productId;
  final String? barcode;
  final String? customName;
  final String categoryId;
  final String? notes;
  final String location;
  final double amount;
  final String unit;
  final DateTime expirationDate;

  const InventoryItemCreateModel({
    required this.productId,
    required this.barcode,
    required this.customName,
    required this.categoryId,
    required this.notes,
    required this.location,
    required this.amount,
    required this.unit,
    required this.expirationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'product_id': productId,
      if (barcode != null) 'barcode': barcode,
      if (customName != null) 'custom_name': customName,
      'category_id': categoryId,
      'notes': notes,
      'location': location,
      'amount': amount,
      'unit': unit,
      'expiration_date': expirationDate.toIso8601String().split('T').first,
    };
  }
}