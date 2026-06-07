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

  const AddManualProductSaveRequested({
    required this.productData,
    required this.inventoryData,
  });

  @override
  List<Object?> get props => [
    productData,
    inventoryData,
  ];
}
