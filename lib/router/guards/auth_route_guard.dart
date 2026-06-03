import 'package:auto_route/auto_route.dart';

import '../../repositories/auth/auth_repository_interface.dart';
import '../router.dart';

class AuthRouteGuard extends AutoRouteGuard {
  final AuthRepositoryInterface _authRepository;

  AuthRouteGuard({
    required AuthRepositoryInterface authRepository,
  }) : _authRepository = authRepository;

  @override
  void onNavigation(
      NavigationResolver resolver,
      StackRouter router,
      ) async {
    final isLoggedIn = await _authRepository.isLoggedIn();

    if (isLoggedIn) {
      resolver.next(true);
    } else {
      router.replace(const AuthRoute());
    }
  }
}