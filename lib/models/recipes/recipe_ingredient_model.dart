class RecipeIngredientModel {
  final int? id;
  final String name;
  final double amount;
  final String unit;
  final String availabilityStatus;
  final String? inventoryItemId;
  final double? inventoryAmount;
  final String? inventoryUnit;
  final bool isAmountComparable;

  const RecipeIngredientModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.availabilityStatus,
    required this.inventoryItemId,
    required this.inventoryAmount,
    required this.inventoryUnit,
    required this.isAmountComparable,
  });

  bool get isAvailable {
    return availabilityStatus == 'available';
  }

  bool get isMissing {
    return availabilityStatus == 'missing';
  }

  bool get isInsufficient {
    return availabilityStatus == 'insufficient';
  }

  bool get isUnknownAmount {
    return availabilityStatus == 'unknown_amount';
  }

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      availabilityStatus: json['availability_status'] as String,
      inventoryItemId: json['inventory_item_id'] as String?,
      inventoryAmount: json['inventory_amount'] == null
          ? null
          : (json['inventory_amount'] as num).toDouble(),
      inventoryUnit: json['inventory_unit'] as String?,
      isAmountComparable: json['is_amount_comparable'] as bool,
    );
  }
}