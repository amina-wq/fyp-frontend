// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Inventory item data model.
// First Written on: Sunday, 07-Jun-2026
// Edited on: Saturday, 18-Jul-2026
import '../categories/categories.dart';

class InventoryItemModel {
  final String id;
  final String userId;
  final String? productId;
  final String? barcode;
  final String? customName;
  final String displayName;
  final String? itemImageUrl;
  final String? productImageUrl;
  final String? productBrand;
  final CategoryModel category;
  final String? notes;
  final String location;
  final double amount;
  final String unit;
  final DateTime expirationDate;
  final DateTime? bestBeforeDate;
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
    required this.itemImageUrl,
    required this.productImageUrl,
    required this.productBrand,
    required this.category,
    required this.notes,
    required this.location,
    required this.amount,
    required this.unit,
    required this.expirationDate,
    this.bestBeforeDate,
    required this.status,
    required this.expiryState,
    required this.addedAt,
    required this.updatedAt,
  });

  String get categoryId => category.id;

  String get categoryKey => category.key;

  String get categoryName => category.name;

  String? get categoryIconUrl => category.iconUrl;

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String?,
      barcode: json['barcode'] as String?,
      customName: json['custom_name'] as String?,
      displayName: json['display_name'] as String,
      itemImageUrl: json['item_image_url'] as String?,
      productImageUrl: json['product_image_url'] as String?,
      productBrand: json['product_brand'] as String?,
      category: CategoryModel.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      notes: json['notes'] as String?,
      location: json['location'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      expirationDate: DateTime.parse(json['expiration_date'] as String),
      bestBeforeDate: json['best_before_date'] != null
          ? DateTime.parse(json['best_before_date'] as String)
          : null,
      status: json['status'] as String,
      expiryState: json['expiry_state'] as String,
      addedAt: DateTime.parse(json['added_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
