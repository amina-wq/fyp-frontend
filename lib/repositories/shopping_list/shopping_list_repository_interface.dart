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
