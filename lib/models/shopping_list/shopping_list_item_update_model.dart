class ShoppingListItemUpdateModel {
  final String? name;
  final String? categoryId;
  final double? amount;
  final String? unit;
  final bool? isChecked;

  const ShoppingListItemUpdateModel({
    this.name,
    this.categoryId,
    this.amount,
    this.unit,
    this.isChecked,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (unit != null) 'unit': unit,
      if (isChecked != null) 'is_checked': isChecked,
    };
  }
}
