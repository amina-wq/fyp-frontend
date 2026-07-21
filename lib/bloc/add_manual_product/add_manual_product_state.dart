// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: States for the manual product creation bloc.
// First Written on: Sunday, 07-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import 'package:equatable/equatable.dart';
import '../../models/inventory/inventory.dart';

abstract class AddManualProductState extends Equatable {
  const AddManualProductState();

  @override
  List<Object?> get props => [];
}

class AddManualProductInitial extends AddManualProductState {
  const AddManualProductInitial();
}

class AddManualProductSaving extends AddManualProductState {
  const AddManualProductSaving();
}

class AddManualProductSuccess extends AddManualProductState {
  final InventoryItemModel item;

  const AddManualProductSuccess({required this.item});

  @override
  List<Object?> get props => [item];
}

class AddManualProductFailure extends AddManualProductState {
  final String message;

  const AddManualProductFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
