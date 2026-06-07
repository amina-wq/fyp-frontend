import 'package:auto_route/auto_route.dart';

import '../features/features.dart';
import '../repositories/auth/auth_repository_interface.dart';
import 'guards/auth_route_guard.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AuthRepositoryInterface authRepository;

  AppRouter({
    required this.authRepository,
  });

  late final AuthRouteGuard _authRouteGuard = AuthRouteGuard(
    authRepository: authRepository,
  );

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: ShellRoute.page,
      path: '/',
      initial: true,
      guards: [_authRouteGuard],
      children: [
        AutoRoute(
          page: HomeRoute.page,
          path: '',
          initial: true,
        ),
        AutoRoute(
          page: ShoppingRoute.page,
          path: 'shopping',
        ),
        AutoRoute(
          page: RecipesRoute.page,
          path: 'recipes',
        ),
        AutoRoute(
          page: SettingsRoute.page,
          path: 'settings',
        ),
      ],
    ),
    AutoRoute(
      page: AuthRoute.page,
      path: '/auth',
    ),
  ];
}