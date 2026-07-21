// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Repository fetching storage and expiry recommendations from the backend.
// First Written on: Tuesday, 14-Jul-2026
// Edited on: Tuesday, 14-Jul-2026
import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/authenticated_api_client.dart';
import '../../models/storage_recommendation/storage_recommendation.dart';
import 'storage_recommendation_repository_interface.dart';

class StorageRecommendationRepository
    implements StorageRecommendationRepositoryInterface {
  final AuthenticatedApiClient _apiClient;

  StorageRecommendationRepository({required AuthenticatedApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<StorageRecommendationModel> getRecommendation(
    StorageRecommendationRequestModel data,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.storageRecommendationsEndpoint,
        data: data.toJson(),
      );

      return StorageRecommendationModel.fromJson(
        response.data as Map<String, dynamic>,
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
