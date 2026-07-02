class InventoryItemUpdateModel {
  final String? customName;
  final String? categoryId;
  final String? notes;
  final String? location;
  final double? amount;
  final String? unit;
  final DateTime? expirationDate;

  const InventoryItemUpdateModel({
    this.customName,
    this.categoryId,
    this.notes,
    this.location,
    this.amount,
    this.unit,
    this.expirationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (customName != null) 'custom_name': customName,
      if (categoryId != null) 'category_id': categoryId,
      if (notes != null) 'notes': notes,
      if (location != null) 'location': location,
      if (amount != null) 'amount': amount,
      if (unit != null) 'unit': unit,
      if (expirationDate != null)
        'expiration_date': expirationDate!.toIso8601String().split('T').first,
    };
  }
}