import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../models/inventory/inventory.dart';
import 'inventory_repository_interface.dart';


class InventoryRepository implements InventoryRepositoryInterface {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  InventoryRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  @override
  Future<InventoryItemModel> createInventoryItem(
      InventoryItemCreateModel data,
      ) async {
    try {
      final accessToken = await _getAccessToken();

      final response = await _apiClient.post(
        ApiConstants.inventoryEndpoint,
        data: data.toJson(),
        accessToken: accessToken,
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
      final accessToken = await _getAccessToken();

      final response = await _apiClient.get(
        ApiConstants.inventoryEndpoint,
        queryParameters: {
          if (categoryId != null) 'category_id': categoryId,
          if (expiryState != null) 'expiry_state': expiryState,
        },
        accessToken: accessToken,
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
      final accessToken = await _getAccessToken();

      final response = await _apiClient.get(
        ApiConstants.inventoryStatsEndpoint,
        accessToken: accessToken,
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
      final accessToken = await _getAccessToken();

      final response = await _apiClient.get(
        ApiConstants.inventoryItemByIdEndpoint(itemId),
        accessToken: accessToken,
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
      final accessToken = await _getAccessToken();

      final response = await _apiClient.patch(
        ApiConstants.inventoryItemByIdEndpoint(itemId),
        data: data.toJson(),
        accessToken: accessToken,
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
      final accessToken = await _getAccessToken();

      final fileName = path.basename(imagePath);

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        ),
      });

      final response = await _apiClient.postMultipart(
        ApiConstants.inventoryItemImageEndpoint(itemId),
        data: formData,
        accessToken: accessToken,
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
      final accessToken = await _getAccessToken();

      final response = await _apiClient.delete(
        ApiConstants.inventoryItemImageEndpoint(itemId),
        accessToken: accessToken,
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
      final accessToken = await _getAccessToken();

      final response = await _apiClient.patch(
        ApiConstants.consumeInventoryItemEndpoint(itemId),
        accessToken: accessToken,
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
      final accessToken = await _getAccessToken();

      final response = await _apiClient.patch(
        ApiConstants.wasteInventoryItemEndpoint(itemId),
        accessToken: accessToken,
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
      final accessToken = await _getAccessToken();

      await _apiClient.delete(
        ApiConstants.inventoryItemByIdEndpoint(itemId),
        accessToken: accessToken,
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