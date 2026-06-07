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
  })  : _productRepository = productRepository,
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
      final createdProduct = await _productRepository.createManualProduct(
        event.productData,
      );

      final inventoryData = InventoryItemCreateModel(
        productId: createdProduct.id,
        barcode: createdProduct.barcode,
        customName: event.inventoryData.customName,
        category: event.inventoryData.category,
        notes: event.inventoryData.notes,
        location: event.inventoryData.location,
        amount: event.inventoryData.amount,
        unit: event.inventoryData.unit,
        expirationDate: event.inventoryData.expirationDate,
      );

      await _inventoryRepository.createInventoryItem(inventoryData);

      emit(const AddManualProductSuccess());
    } catch (error) {
      emit(
        AddManualProductFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}