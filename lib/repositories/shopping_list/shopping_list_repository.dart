import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../models/shopping_list/shopping_list.dart';
import 'shopping_list_repository_interface.dart';

class ShoppingListRepository implements ShoppingListRepositoryInterface {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  ShoppingListRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  @override
  Future<List<ShoppingListItemModel>> getShoppingListItems({
    bool includeChecked = true,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      final response = await _apiClient.get(
        ApiConstants.shoppingListEndpoint,
        queryParameters: {
          'include_checked': includeChecked,
        },
        accessToken: accessToken,
      );

      final data = response.data as List<dynamic>;

      return data
          .map(
            (item) => ShoppingListItemModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<ShoppingListItemModel> createShoppingListItem(
      ShoppingListItemCreateModel data,
      ) async {
    try {
      final accessToken = await _getAccessToken();

      final response = await _apiClient.post(
        ApiConstants.shoppingListEndpoint,
        data: data.toJson(),
        accessToken: accessToken,
      );

      return ShoppingListItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<ShoppingListItemModel> updateShoppingListItem({
    required String itemId,
    required ShoppingListItemUpdateModel data,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      final response = await _apiClient.patch(
        ApiConstants.shoppingListItemByIdEndpoint(itemId),
        data: data.toJson(),
        accessToken: accessToken,
      );

      return ShoppingListItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<ShoppingListItemModel> toggleShoppingListItem(String itemId) async {
    try {
      final accessToken = await _getAccessToken();

      final response = await _apiClient.patch(
        ApiConstants.shoppingListItemCheckEndpoint(itemId),
        accessToken: accessToken,
      );

      return ShoppingListItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<void> deleteShoppingListItem(String itemId) async {
    try {
      final accessToken = await _getAccessToken();

      await _apiClient.delete(
        ApiConstants.shoppingListItemByIdEndpoint(itemId),
        accessToken: accessToken,
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<void> clearCheckedItems() async {
    try {
      final accessToken = await _getAccessToken();

      await _apiClient.delete(
        ApiConstants.shoppingListCheckedEndpoint,
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