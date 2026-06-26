class ShoppingListItemCreateModel {
  final String name;
  final String category;
  final double? amount;
  final String? unit;
  final String source;
  final String? sourceId;

  const ShoppingListItemCreateModel({
    required this.name,
    required this.category,
    this.amount,
    this.unit,
    this.source = 'manual',
    this.sourceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'amount': amount,
      'unit': unit,
      'source': source,
      'source_id': sourceId,
    };
  }
}