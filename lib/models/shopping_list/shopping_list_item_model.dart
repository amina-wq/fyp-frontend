import '../categories/categories.dart';

class ShoppingListItemModel {
  final String id;
  final String userId;
  final String name;
  final CategoryModel category;
  final double? amount;
  final String? unit;
  final bool isChecked;
  final String source;
  final String? sourceId;
  final DateTime addedAt;
  final DateTime updatedAt;

  const ShoppingListItemModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.amount,
    required this.unit,
    required this.isChecked,
    required this.source,
    required this.sourceId,
    required this.addedAt,
    required this.updatedAt,
  });

  String get categoryId => category.id;

  String get categoryKey => category.key;

  String get categoryName => category.name;

  String? get categoryIconUrl => category.iconUrl;

  factory ShoppingListItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      category: CategoryModel.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      amount: json['amount'] == null ? null : (json['amount'] as num).toDouble(),
      unit: json['unit'] as String?,
      isChecked: json['is_checked'] as bool,
      source: json['source'] as String,
      sourceId: json['source_id'] as String?,
      addedAt: DateTime.parse(json['added_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}