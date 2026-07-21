// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Abstract interface for the inventory repository.
// First Written on: Tuesday, 19-May-2026
// Edited on: Sunday, 12-Jul-2026
import '../../models/inventory/inventory.dart';

abstract class InventoryRepositoryInterface {
  Future<InventoryItemModel> createInventoryItem(InventoryItemCreateModel data);

  Future<List<InventoryItemModel>> getInventoryItems({
    String? categoryId,
    String? expiryState,
  });

  Future<InventoryStatsModel> getInventoryStats();

  Future<InventoryItemModel> getInventoryItemById(String itemId);

  Future<InventoryItemModel> updateInventoryItem({
    required String itemId,
    required InventoryItemUpdateModel data,
  });

  Future<InventoryItemModel> uploadInventoryItemImage({
    required String itemId,
    required String imagePath,
  });

  Future<InventoryItemModel> deleteInventoryItemImage(String itemId);

  Future<InventoryItemModel> consumeInventoryItem(String itemId);

  Future<InventoryItemModel> wasteInventoryItem(String itemId);

  Future<void> deleteInventoryItem(String itemId);
}
