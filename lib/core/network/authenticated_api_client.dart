import 'package:dio/dio.dart';

import '../../models/auth/auth.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';

class AuthenticatedApiClient {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthenticatedApiClient({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _authorizedRequest(
      (accessToken) => _apiClient.get(
        path,
        queryParameters: queryParameters,
        accessToken: accessToken,
      ),
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _authorizedRequest(
      (accessToken) => _apiClient.post(
        path,
        data: data,
        queryParameters: queryParameters,
        accessToken: accessToken,
      ),
    );
  }

  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _authorizedRequest(
      (accessToken) => _apiClient.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        accessToken: accessToken,
      ),
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _authorizedRequest(
      (accessToken) => _apiClient.put(
        path,
        data: data,
        queryParameters: queryParameters,
        accessToken: accessToken,
      ),
    );
  }

  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _authorizedRequest(
      (accessToken) => _apiClient.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        accessToken: accessToken,
      ),
    );
  }

  Future<Response<dynamic>> postMultipart(
    String path, {
    required Future<FormData> Function() dataBuilder,
  }) {
    return _authorizedRequest((accessToken) async {
      final formData = await dataBuilder();

      return _apiClient.postMultipart(
        path,
        data: formData,
        accessToken: accessToken,
      );
    });
  }

  Future<Response<dynamic>> _authorizedRequest(
    Future<Response<dynamic>> Function(String accessToken) request,
  ) async {
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    try {
      return await request(accessToken);
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) {
        rethrow;
      }

      final refreshedAccessToken = await _refreshAccessToken();

      return request(refreshedAccessToken);
    }
  }

  Future<String> _refreshAccessToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null) {
      throw Exception('Refresh token not found');
    }

    final response = await _apiClient.post(
      ApiConstants.refreshEndpoint,
      data: {'refresh_token': refreshToken},
    );

    final tokens = TokenModel.fromJson(response.data as Map<String, dynamic>);

    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );

    return tokens.accessToken;
  }
}
