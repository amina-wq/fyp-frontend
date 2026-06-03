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
      page: HomeRoute.page,
      path: '/',
      initial: true,
      guards: [_authRouteGuard],
    ),
    AutoRoute(
      page: AuthRoute.page,
      path: '/auth',
    ),
  ];
}