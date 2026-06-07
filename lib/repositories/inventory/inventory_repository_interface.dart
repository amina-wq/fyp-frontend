import '../../models/inventory/inventory.dart';

abstract class InventoryRepositoryInterface {
  Future<InventoryItemModel> createInventoryItem(
      InventoryItemCreateModel data,
      );

  Future<List<InventoryItemModel>> getInventoryItems({
    String? category,
    String? expiryState,
  });

  Future<InventoryStatsModel> getInventoryStats();

  Future<InventoryItemModel> getInventoryItemById(String itemId);

  Future<InventoryItemModel> updateInventoryItem({
    required String itemId,
    required InventoryItemUpdateModel data,
  });

  Future<InventoryItemModel> consumeInventoryItem(String itemId);

  Future<InventoryItemModel> wasteInventoryItem(String itemId);

  Future<void> deleteInventoryItem(String itemId);
}
