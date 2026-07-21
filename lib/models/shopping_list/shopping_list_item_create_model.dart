// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Payload model for creating a shopping list item.
// First Written on: Friday, 26-Jun-2026
// Edited on: Sunday, 12-Jul-2026
class ShoppingListItemCreateModel {
  final String name;
  final String categoryId;
  final double? amount;
  final String? unit;
  final String source;
  final String? sourceId;

  const ShoppingListItemCreateModel({
    required this.name,
    required this.categoryId,
    this.amount,
    this.unit,
    this.source = 'manual',
    this.sourceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category_id': categoryId,
      'amount': amount,
      'unit': unit,
      'source': source,
      'source_id': sourceId,
    };
  }
}
