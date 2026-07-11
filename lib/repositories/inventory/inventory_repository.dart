import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import '../../core/constants/api_constants.dart';
import '../../core/network/authenticated_api_client.dart';
import '../../models/inventory/inventory.dart';
import 'inventory_repository_interface.dart';

class InventoryRepository implements InventoryRepositoryInterface {
  final AuthenticatedApiClient _apiClient;

  InventoryRepository({
    required AuthenticatedApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<InventoryItemModel> createInventoryItem(
      InventoryItemCreateModel data,
      ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.inventoryEndpoint,
        data: data.toJson(),
      );

      return InventoryItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<List<InventoryItemModel>> getInventoryItems({
    String? categoryId,
    String? expiryState,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.inventoryEndpoint,
        queryParameters: {
          if (categoryId != null) 'category_id': categoryId,
          if (expiryState != null) 'expiry_state': expiryState,
        },
      );

      final data = response.data as List<dynamic>;

      return data
          .map(
            (item) => InventoryItemModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<InventoryStatsModel> getInventoryStats() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.inventoryStatsEndpoint,
      );

      return InventoryStatsModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<InventoryItemModel> getInventoryItemById(String itemId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.inventoryItemByIdEndpoint(itemId),
      );

      return InventoryItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<InventoryItemModel> updateInventoryItem({
    required String itemId,
    required InventoryItemUpdateModel data,
  }) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.inventoryItemByIdEndpoint(itemId),
        data: data.toJson(),
      );

      return InventoryItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<InventoryItemModel> uploadInventoryItemImage({
    required String itemId,
    required String imagePath,
  }) async {
    try {
      final response = await _apiClient.postMultipart(
        ApiConstants.inventoryItemImageEndpoint(itemId),
        dataBuilder: () async {
          final fileName = path.basename(imagePath);

          return FormData.fromMap({
            'image': await MultipartFile.fromFile(
              imagePath,
              filename: fileName,
            ),
          });
        },
      );

      return InventoryItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<InventoryItemModel> deleteInventoryItemImage(String itemId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.inventoryItemImageEndpoint(itemId),
      );

      return InventoryItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<InventoryItemModel> consumeInventoryItem(String itemId) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.consumeInventoryItemEndpoint(itemId),
      );

      return InventoryItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<InventoryItemModel> wasteInventoryItem(String itemId) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.wasteInventoryItemEndpoint(itemId),
      );

      return InventoryItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<void> deleteInventoryItem(String itemId) async {
    try {
      await _apiClient.delete(
        ApiConstants.inventoryItemByIdEndpoint(itemId),
      );
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