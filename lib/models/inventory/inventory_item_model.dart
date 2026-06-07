class InventoryItemModel {
  final String id;
  final String userId;
  final String? productId;
  final String? barcode;
  final String? customName;
  final String displayName;
  final String category;
  final String? notes;
  final String location;
  final double amount;
  final String unit;
  final DateTime expirationDate;
  final String status;
  final String expiryState;
  final DateTime addedAt;
  final DateTime updatedAt;

  const InventoryItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.barcode,
    required this.customName,
    required this.displayName,
    required this.category,
    required this.notes,
    required this.location,
    required this.amount,
    required this.unit,
    required this.expirationDate,
    required this.status,
    required this.expiryState,
    required this.addedAt,
    required this.updatedAt,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String?,
      barcode: json['barcode'] as String?,
      customName: json['custom_name'] as String?,
      displayName: json['display_name'] as String,
      category: json['category'] as String,
      notes: json['notes'] as String?,
      location: json['location'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      expirationDate: DateTime.parse(json['expiration_date'] as String),
      status: json['status'] as String,
      expiryState: json['expiry_state'] as String,
      addedAt: DateTime.parse(json['added_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}