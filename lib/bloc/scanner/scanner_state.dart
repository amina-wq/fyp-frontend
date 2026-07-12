import 'package:equatable/equatable.dart';

import '../../models/product/product.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {
  const ScannerInitial();
}

class ScannerLoading extends ScannerState {
  const ScannerLoading();
}

class ScannerProductFound extends ScannerState {
  final ProductModel product;

  const ScannerProductFound({required this.product});

  @override
  List<Object?> get props => [product];
}

class ScannerProductNotFound extends ScannerState {
  final String barcode;

  const ScannerProductNotFound({required this.barcode});

  @override
  List<Object?> get props => [barcode];
}

class ScannerFailure extends ScannerState {
  final String message;

  const ScannerFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
