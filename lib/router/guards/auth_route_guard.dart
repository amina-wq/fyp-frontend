import 'package:auto_route/auto_route.dart';

import '../../repositories/auth/auth_repository_interface.dart';
import '../router.dart';

class AuthRouteGuard extends AutoRouteGuard {
  final AuthRepositoryInterface authRepository;

  AuthRouteGuard({required this.authRepository});

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final hasTokens = await authRepository.isLoggedIn();

    if (!hasTokens) {
      resolver.redirectUntil(const AuthRoute());
      return;
    }

    try {
      await authRepository.getCurrentUser();

      resolver.next();
    } catch (_) {
      try {
        await authRepository.refreshTokens();

        resolver.next();
      } catch (_) {
        await authRepository.logout();

        resolver.redirectUntil(const AuthRoute());
      }
    }
  }
}
