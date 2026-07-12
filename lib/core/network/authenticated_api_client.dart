import 'package:dio/dio.dart';

import '../../models/auth/auth.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import '../logging/app_logger.dart';
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
      AppLogger.warning(
        'Authenticated request blocked because access token is missing.',
        name: 'AuthenticatedApiClient',
      );

      throw Exception('Access token not found');
    }

    try {
      return await request(accessToken);
    } on DioException catch (error, stackTrace) {
      final statusCode = error.response?.statusCode;

      if (statusCode != 401) {
        AppLogger.error(
          'Authenticated request failed with statusCode=$statusCode.',
          name: 'AuthenticatedApiClient',
          error: error,
          stackTrace: stackTrace,
        );

        rethrow;
      }

      AppLogger.warning(
        'Access token expired. Trying to refresh token.',
        name: 'AuthenticatedApiClient',
      );

      final refreshedAccessToken = await _refreshAccessToken();

      AppLogger.info(
        'Access token refreshed successfully. Retrying request.',
        name: 'AuthenticatedApiClient',
      );

      return request(refreshedAccessToken);
    }
  }

  Future<String> _refreshAccessToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null) {
      AppLogger.warning(
        'Token refresh failed because refresh token is missing.',
        name: 'AuthenticatedApiClient',
      );

      throw Exception('Refresh token not found');
    }

    try {
      final response = await _apiClient.post(
        ApiConstants.refreshEndpoint,
        data: {'refresh_token': refreshToken},
      );

      final tokens = TokenModel.fromJson(response.data as Map<String, dynamic>);

      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      AppLogger.info(
        'Token refresh completed and tokens were saved.',
        name: 'AuthenticatedApiClient',
      );

      return tokens.accessToken;
    } on DioException catch (error, stackTrace) {
      AppLogger.error(
        'Token refresh request failed.',
        name: 'AuthenticatedApiClient',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}
