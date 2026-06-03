import '../../models/auth/auth.dart';

abstract class AuthRepositoryInterface {
  Future<TokenModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<TokenModel> login({
    required String email,
    required String password,
  });

  Future<TokenModel> refreshTokens();

  Future<UserModel> getCurrentUser();

  Future<void> logout();

  Future<bool> isLoggedIn();
}