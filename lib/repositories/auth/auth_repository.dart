import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../models/auth/auth.dart';
import 'auth_repository_interface.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  @override
  Future<TokenModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.registerEndpoint,
        data: {'name': name, 'email': email, 'password': password},
      );

      final tokens = TokenModel.fromJson(response.data as Map<String, dynamic>);

      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      return tokens;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<TokenModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      final tokens = TokenModel.fromJson(response.data as Map<String, dynamic>);

      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      return tokens;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<TokenModel> refreshTokens() async {
    try {
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

      return tokens;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _authorizedRequest(
        (accessToken) =>
            _apiClient.get(ApiConstants.meEndpoint, accessToken: accessToken),
      );

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<UserModel> updateName({required String name}) async {
    try {
      final response = await _authorizedRequest(
        (accessToken) => _apiClient.patch(
          ApiConstants.updateNameEndpoint,
          accessToken: accessToken,
          data: {'name': name},
        ),
      );

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<UserModel> updateSettings({
    required List<int> notificationDaysBefore,
    required bool expiryNotificationsEnabled,
    required String themeMode,
  }) async {
    try {
      final response = await _authorizedRequest(
        (accessToken) => _apiClient.patch(
          ApiConstants.updateSettingsEndpoint,
          accessToken: accessToken,
          data: {
            'notification_days_before': notificationDaysBefore,
            'expiry_notifications_enabled': expiryNotificationsEnabled,
            'theme_mode': themeMode,
          },
        ),
      );

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<UserModel> updateFcmToken({required String? fcmToken}) async {
    try {
      final response = await _authorizedRequest(
        (accessToken) => _apiClient.patch(
          ApiConstants.fcmTokenEndpoint,
          accessToken: accessToken,
          data: {'fcm_token': fcmToken},
        ),
      );

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  @override
  Future<void> logout() async {
    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    try {
      if (accessToken != null && refreshToken != null) {
        await _apiClient.post(
          ApiConstants.logoutEndpoint,
          accessToken: accessToken,
          data: {'refresh_token': refreshToken},
        );
      }
    } on DioException {
      // Even if backend logout fails because the token is already expired,
      // local tokens must still be removed so the user is logged out on this device.
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return _tokenStorage.hasTokens();
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

      final refreshedTokens = await refreshTokens();

      return request(refreshedTokens.accessToken);
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
