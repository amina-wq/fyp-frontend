// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Events for the inventory bloc.
// First Written on: Sunday, 07-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import 'package:equatable/equatable.dart';

import '../../models/inventory/inventory.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

class InventoryLoadRequested extends InventoryEvent {
  const InventoryLoadRequested();
}

class InventoryFilterChanged extends InventoryEvent {
  final String? categoryId;
  final String? expiryState;

  const InventoryFilterChanged({this.categoryId, this.expiryState});

  @override
  List<Object?> get props => [categoryId, expiryState];
}

class InventoryItemCreateRequested extends InventoryEvent {
  final InventoryItemCreateModel data;
  final String? imagePath;

  const InventoryItemCreateRequested({required this.data, this.imagePath});

  @override
  List<Object?> get props => [data, imagePath];
}

class InventoryItemUpdateRequested extends InventoryEvent {
  final String itemId;
  final InventoryItemUpdateModel data;

  const InventoryItemUpdateRequested({
    required this.itemId,
    required this.data,
  });

  @override
  List<Object?> get props => [itemId, data];
}

class InventoryItemImageUploadRequested extends InventoryEvent {
  final String itemId;
  final String imagePath;

  const InventoryItemImageUploadRequested({
    required this.itemId,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [itemId, imagePath];
}

class InventoryItemImageDeleteRequested extends InventoryEvent {
  final String itemId;

  const InventoryItemImageDeleteRequested({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class InventoryItemConsumeRequested extends InventoryEvent {
  final String itemId;

  const InventoryItemConsumeRequested({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class InventoryItemWasteRequested extends InventoryEvent {
  final String itemId;

  const InventoryItemWasteRequested({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class InventoryItemDeleteRequested extends InventoryEvent {
  final String itemId;

  const InventoryItemDeleteRequested({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}
