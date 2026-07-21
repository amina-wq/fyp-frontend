// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Low-level Dio HTTP client wrapper for backend requests.
// First Written on: Wednesday, 03-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? accessToken,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: _buildOptions(accessToken),
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? accessToken,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _buildOptions(accessToken),
    );
  }

  Future<Response<dynamic>> postMultipart(
    String path, {
    required FormData data,
    String? accessToken,
  }) async {
    return _dio.post(
      path,
      data: data,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? accessToken,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _buildOptions(accessToken),
    );
  }

  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? accessToken,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _buildOptions(accessToken),
    );
  }

  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? accessToken,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _buildOptions(accessToken),
    );
  }

  Options? _buildOptions(String? accessToken) {
    if (accessToken == null) {
      return null;
    }

    return Options(headers: {'Authorization': 'Bearer $accessToken'});
  }
}
