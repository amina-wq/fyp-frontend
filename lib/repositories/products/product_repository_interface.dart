// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Abstract interface for the product repository.
// First Written on: Sunday, 07-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import '../../models/product/product.dart';

abstract class ProductRepositoryInterface {
  Future<ProductModel> getProductByBarcode(String barcode);

  Future<ProductModel> getProductById(String productId);

  Future<ProductModel> createManualProduct(ManualProductCreateModel data);
}
