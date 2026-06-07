import '../../models/product/product.dart';

abstract class ProductRepositoryInterface {
  Future<ProductModel> getProductByBarcode(String barcode);

  Future<ProductModel> getProductById(String productId);

  Future<ProductModel> createManualProduct(
      ManualProductCreateModel data,
      );
}
