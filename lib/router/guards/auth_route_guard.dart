// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Route guard that redirects unauthenticated users to the auth screen.
// First Written on: Wednesday, 03-Jun-2026
// Edited on: Sunday, 12-Jul-2026
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
