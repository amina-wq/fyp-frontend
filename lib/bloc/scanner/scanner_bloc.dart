import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/products/product_repository_interface.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final ProductRepositoryInterface _productRepository;

  ScannerBloc({required ProductRepositoryInterface productRepository})
    : _productRepository = productRepository,
      super(const ScannerInitial()) {
    on<ScannerBarcodeDetected>(_onBarcodeDetected);
    on<ScannerResetRequested>(_onResetRequested);
  }

  Future<void> _onBarcodeDetected(
    ScannerBarcodeDetected event,
    Emitter<ScannerState> emit,
  ) async {
    emit(const ScannerLoading());

    try {
      final product = await _productRepository.getProductByBarcode(
        event.barcode,
      );

      emit(ScannerProductFound(product: product));
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');

      if (message.toLowerCase().contains('not found')) {
        emit(ScannerProductNotFound(barcode: event.barcode));
        return;
      }

      emit(ScannerFailure(message: message));
    }
  }

  void _onResetRequested(
    ScannerResetRequested event,
    Emitter<ScannerState> emit,
  ) {
    emit(const ScannerInitial());
  }
}
