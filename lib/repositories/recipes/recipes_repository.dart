// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Repository fetching recipe recommendations and recipe details.
// First Written on: Tuesday, 30-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/authenticated_api_client.dart';
import '../../models/recipes/recipes.dart';
import 'recipes_repository_interface.dart';

class RecipesRepository implements RecipesRepositoryInterface {
  final AuthenticatedApiClient _apiClient;

  RecipesRepository({required AuthenticatedApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<RecipeSummaryModel>> getRecipesByInventory({
    int number = 10,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.recipesByIngredientsEndpoint,
        data: {'number': number},
      );

      final data = response.data as List<dynamic>;

      return data
          .map(
            (item) => RecipeSummaryModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<RecipeDetailModel> getRecipeDetails({
    required int spoonacularId,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.recipeDetailsEndpoint(spoonacularId),
      );

      return RecipeDetailModel.fromJson(response.data as Map<String, dynamic>);
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

      if (detail is List) {
        return detail.toString();
      }

      if (detail != null) {
        return detail.toString();
      }
    }

    if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Connection timeout. Please check backend connection.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to backend. Please check server or internet connection.';
    }

    return 'Something went wrong. Please try again.';
  }
}
