// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Events for the manual product creation bloc.
// First Written on: Sunday, 07-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import 'package:equatable/equatable.dart';

import '../../models/inventory/inventory.dart';
import '../../models/product/product.dart';

abstract class AddManualProductEvent extends Equatable {
  const AddManualProductEvent();

  @override
  List<Object?> get props => [];
}

class AddManualProductSaveRequested extends AddManualProductEvent {
  final ManualProductCreateModel productData;
  final InventoryItemCreateModel inventoryData;
  final String? imagePath;

  const AddManualProductSaveRequested({
    required this.productData,
    required this.inventoryData,
    this.imagePath,
  });

  @override
  List<Object?> get props => [productData, inventoryData, imagePath];
}
