// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Repository implementing shopping list CRUD API calls.
// First Written on: Friday, 26-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/authenticated_api_client.dart';
import '../../models/shopping_list/shopping_list.dart';
import 'shopping_list_repository_interface.dart';

class ShoppingListRepository implements ShoppingListRepositoryInterface {
  final AuthenticatedApiClient _apiClient;

  ShoppingListRepository({required AuthenticatedApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ShoppingListItemModel>> getShoppingListItems({
    bool includeChecked = true,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.shoppingListEndpoint,
        queryParameters: {'include_checked': includeChecked},
      );

      final data = response.data as List<dynamic>;

      return data
          .map(
            (item) =>
                ShoppingListItemModel.fromJson(item as Map<String, dynamic>),
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
      final response = await _apiClient.post(
        ApiConstants.shoppingListEndpoint,
        data: data.toJson(),
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
      final response = await _apiClient.patch(
        ApiConstants.shoppingListItemByIdEndpoint(itemId),
        data: data.toJson(),
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
      final response = await _apiClient.patch(
        ApiConstants.shoppingListItemCheckEndpoint(itemId),
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
      await _apiClient.delete(
        ApiConstants.shoppingListItemByIdEndpoint(itemId),
      );
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<void> clearCheckedItems() async {
    try {
      await _apiClient.delete(ApiConstants.shoppingListCheckedEndpoint);
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
