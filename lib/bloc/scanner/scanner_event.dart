// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Events for the scanner bloc.
// First Written on: Friday, 19-Jun-2026
// Edited on: Sunday, 12-Jul-2026
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
