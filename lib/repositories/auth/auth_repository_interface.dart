// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Abstract interface for the authentication repository.
// First Written on: Tuesday, 19-May-2026
// Edited on: Sunday, 12-Jul-2026
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
