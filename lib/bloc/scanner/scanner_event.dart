import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class ScannerBarcodeDetected extends ScannerEvent {
  final String barcode;

  const ScannerBarcodeDetected({required this.barcode});

  @override
  List<Object?> get props => [barcode];
}

class ScannerResetRequested extends ScannerEvent {
  const ScannerResetRequested();
}
