// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Abstract interface for the shopping list repository.
// First Written on: Friday, 26-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import '../../models/shopping_list/shopping_list.dart';

abstract class ShoppingListRepositoryInterface {
  Future<List<ShoppingListItemModel>> getShoppingListItems({
    bool includeChecked = true,
  });

  Future<ShoppingListItemModel> createShoppingListItem(
    ShoppingListItemCreateModel data,
  );

  Future<ShoppingListItemModel> updateShoppingListItem({
    required String itemId,
    required ShoppingListItemUpdateModel data,
  });

  Future<ShoppingListItemModel> toggleShoppingListItem(String itemId);

  Future<void> deleteShoppingListItem(String itemId);

  Future<void> clearCheckedItems();
}
