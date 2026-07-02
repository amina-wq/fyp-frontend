import '../../models/inventory/inventory.dart';

abstract class InventoryRepositoryInterface {
  Future<InventoryItemModel> createInventoryItem(
      InventoryItemCreateModel data,
      );

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
