class ShoppingListItemUpdateModel {
  final String? name;
  final String? category;
  final double? amount;
  final String? unit;
  final bool? isChecked;

  const ShoppingListItemUpdateModel({
    this.name,
    this.category,
    this.amount,
    this.unit,
    this.isChecked,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (unit != null) 'unit': unit,
      if (isChecked != null) 'is_checked': isChecked,
    };
  }
}