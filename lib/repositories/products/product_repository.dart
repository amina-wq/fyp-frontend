// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Repository implementing product lookup and manual product creation API calls.
// First Written on: Sunday, 07-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/authenticated_api_client.dart';
import '../../models/product/product.dart';
import 'product_repository_interface.dart';

class ProductRepository implements ProductRepositoryInterface {
  final AuthenticatedApiClient _apiClient;

  ProductRepository({required AuthenticatedApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<ProductModel> getProductByBarcode(String barcode) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.productByBarcodeEndpoint(barcode),
      );

      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<ProductModel> getProductById(String productId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.productByIdEndpoint(productId),
      );

      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<ProductModel> createManualProduct(
    ManualProductCreateModel data,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.manualProductEndpoint,
        data: data.toJson(),
      );

      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  String _extractErrorMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final detail = responseData['detail'];

      if (detail is String) {
        return detail;
      }
    }

    return 'Something went wrong. Please try again.';
  }
}
