import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/inventory/inventory.dart';
import '../../repositories/inventory/inventory_repository_interface.dart';
import '../../repositories/products/product_repository_interface.dart';
import 'add_manual_product_event.dart';
import 'add_manual_product_state.dart';

class AddManualProductBloc
    extends Bloc<AddManualProductEvent, AddManualProductState> {
  final ProductRepositoryInterface _productRepository;
  final InventoryRepositoryInterface _inventoryRepository;

  AddManualProductBloc({
    required ProductRepositoryInterface productRepository,
    required InventoryRepositoryInterface inventoryRepository,
  }) : _productRepository = productRepository,
       _inventoryRepository = inventoryRepository,
       super(const AddManualProductInitial()) {
    on<AddManualProductSaveRequested>(_onSaveRequested);
  }

  Future<void> _onSaveRequested(
    AddManualProductSaveRequested event,
    Emitter<AddManualProductState> emit,
  ) async {
    emit(const AddManualProductSaving());

    try {
      final barcode = event.productData.barcode?.trim();
      final hasBarcode = barcode != null && barcode.isNotEmpty;

      InventoryItemCreateModel inventoryData;

      if (hasBarcode) {
        final createdProduct = await _productRepository.createManualProduct(
          event.productData,
        );

        inventoryData = InventoryItemCreateModel(
          productId: createdProduct.id,
          barcode: createdProduct.barcode,
          customName: event.inventoryData.customName,
          categoryId: event.inventoryData.categoryId,
          notes: event.inventoryData.notes,
          location: event.inventoryData.location,
          amount: event.inventoryData.amount,
          unit: event.inventoryData.unit,
          expirationDate: event.inventoryData.expirationDate,
        );
      } else {
        inventoryData = InventoryItemCreateModel(
          productId: null,
          barcode: null,
          customName: event.productData.name,
          categoryId: event.inventoryData.categoryId,
          notes: event.inventoryData.notes,
          location: event.inventoryData.location,
          amount: event.inventoryData.amount,
          unit: event.inventoryData.unit,
          expirationDate: event.inventoryData.expirationDate,
        );
      }

      var createdItem = await _inventoryRepository.createInventoryItem(
        inventoryData,
      );

      final imagePath = event.imagePath;

      if (imagePath != null && imagePath.isNotEmpty) {
        createdItem = await _inventoryRepository.uploadInventoryItemImage(
          itemId: createdItem.id,
          imagePath: imagePath,
        );
      }

      emit(AddManualProductSuccess(item: createdItem));
    } catch (error) {
      emit(
        AddManualProductFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
