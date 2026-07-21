// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Events for the shopping list bloc.
// First Written on: Friday, 26-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import '../../models/shopping_list/shopping_list.dart';

abstract class ShoppingListEvent {
  const ShoppingListEvent();
}

class ShoppingListLoadRequested extends ShoppingListEvent {
  const ShoppingListLoadRequested();
}

class ShoppingListItemCreateRequested extends ShoppingListEvent {
  final ShoppingListItemCreateModel item;

  const ShoppingListItemCreateRequested({required this.item});
}

class ShoppingListItemToggleRequested extends ShoppingListEvent {
  final String itemId;

  const ShoppingListItemToggleRequested({required this.itemId});
}

class ShoppingListItemDeleteRequested extends ShoppingListEvent {
  final String itemId;

  const ShoppingListItemDeleteRequested({required this.itemId});
}

class ShoppingListCheckedClearRequested extends ShoppingListEvent {
  const ShoppingListCheckedClearRequested();
}
