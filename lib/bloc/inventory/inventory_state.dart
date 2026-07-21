// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: States for the inventory bloc.
// First Written on: Sunday, 07-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import 'package:equatable/equatable.dart';

import '../../models/inventory/inventory.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

class InventoryLoadInProgress extends InventoryState {
  const InventoryLoadInProgress();
}

class InventoryLoadSuccess extends InventoryState {
  final List<InventoryItemModel> items;
  final InventoryStatsModel stats;
  final String? selectedCategoryId;
  final String? selectedExpiryState;

  const InventoryLoadSuccess({
    required this.items,
    required this.stats,
    required this.selectedCategoryId,
    this.selectedExpiryState,
  });

  @override
  List<Object?> get props => [
    items,
    stats,
    selectedCategoryId,
    selectedExpiryState,
  ];
}

class InventoryActionInProgress extends InventoryState {
  final List<InventoryItemModel> items;
  final InventoryStatsModel stats;
  final String? selectedCategoryId;
  final String? selectedExpiryState;

  const InventoryActionInProgress({
    required this.items,
    required this.stats,
    this.selectedCategoryId,
    this.selectedExpiryState,
  });

  @override
  List<Object?> get props => [
    items,
    stats,
    selectedCategoryId,
    selectedExpiryState,
  ];
}

class InventoryFailure extends InventoryState {
  final String message;

  const InventoryFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
