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
