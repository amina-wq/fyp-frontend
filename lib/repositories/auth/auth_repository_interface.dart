import '../../models/auth/auth.dart';

abstract class AuthRepositoryInterface {
  Future<TokenModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<TokenModel> login({required String email, required String password});

  Future<TokenModel> refreshTokens();

  Future<UserModel> getCurrentUser();

  Future<UserModel> updateName({required String name});

  Future<UserModel> updateSettings({
    required List<int> notificationDaysBefore,
    required bool expiryNotificationsEnabled,
    required String themeMode,
  });

  Future<UserModel> updateFcmToken({required String? fcmToken});

  Future<void> logout();

  Future<bool> isLoggedIn();
}
