import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../models/product/product.dart';
import 'product_repository_interface.dart';

class ProductRepository implements ProductRepositoryInterface {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  ProductRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  @override
  Future<ProductModel> getProductByBarcode(String barcode) async {
    try {
      final accessToken = await _getAccessToken();

      final response = await _apiClient.get(
        ApiConstants.productByBarcodeEndpoint(barcode),
        accessToken: accessToken,
      );

      return ProductModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<ProductModel> getProductById(String productId) async {
    try {
      final accessToken = await _getAccessToken();

      final response = await _apiClient.get(
        ApiConstants.productByIdEndpoint(productId),
        accessToken: accessToken,
      );

      return ProductModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<ProductModel> createManualProduct(
      ManualProductCreateModel data,
      ) async {
    try {
      final accessToken = await _getAccessToken();

      final response = await _apiClient.post(
        ApiConstants.manualProductEndpoint,
        data: data.toJson(),
        accessToken: accessToken,
      );

      return ProductModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<String> _getAccessToken() async {
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    return accessToken;
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