import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/authenticated_api_client.dart';
import '../../models/categories/categories.dart';
import 'categories_repository_interface.dart';

class CategoriesRepository implements CategoriesRepositoryInterface {
  final AuthenticatedApiClient _apiClient;

  CategoriesRepository({required AuthenticatedApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.categoriesEndpoint);

      final data = response.data as List<dynamic>;

      return data
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
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
