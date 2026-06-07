class InventoryItemUpdateModel {
  final String? customName;
  final String? category;
  final String? notes;
  final String? location;

  final double? amount;
  final String? unit;

  final DateTime? expirationDate;

  const InventoryItemUpdateModel({
    this.customName,
    this.category,
    this.notes,
    this.location,
    this.amount,
    this.unit,
    this.expirationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (customName != null) 'custom_name': customName,
      if (category != null) 'category': category,
      if (notes != null) 'notes': notes,
      if (location != null) 'location': location,
      if (amount != null) 'amount': amount,
      if (unit != null) 'unit': unit,
      if (expirationDate != null)
        'expiration_date': expirationDate!.toIso8601String().split('T').first,
    };
  }
}