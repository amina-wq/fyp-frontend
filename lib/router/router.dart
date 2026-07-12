import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../features/features.dart';
import '../repositories/auth/auth_repository_interface.dart';
import 'guards/auth_route_guard.dart';
import '../models/inventory/inventory.dart';
import '../models/product/product.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AuthRepositoryInterface authRepository;

  AppRouter({required this.authRepository});

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
        AutoRoute(page: HomeRoute.page, path: '', initial: true),
        AutoRoute(page: ShoppingRoute.page, path: 'shopping'),
        AutoRoute(page: RecipesRoute.page, path: 'recipes'),
        AutoRoute(page: SettingsRoute.page, path: 'settings'),
      ],
    ),
    AutoRoute(page: AuthRoute.page, path: '/auth'),
    AutoRoute(
      page: AddManualProductRoute.page,
      path: '/add-manual-product',
      guards: [_authRouteGuard],
    ),
    AutoRoute(
      page: ScannerRoute.page,
      path: '/scanner',
      guards: [_authRouteGuard],
    ),
    AutoRoute(
      page: AddScannedProductRoute.page,
      path: '/add-scanned-product',
      guards: [_authRouteGuard],
    ),
    AutoRoute(
      page: InventoryItemDetailsRoute.page,
      path: '/inventory-item-details',
      guards: [_authRouteGuard],
    ),
    AutoRoute(
      page: EditInventoryItemRoute.page,
      path: '/edit-inventory-item',
      guards: [_authRouteGuard],
    ),
    AutoRoute(
      page: RecipeDetailRoute.page,
      path: '/recipe-detail',
      guards: [_authRouteGuard],
    ),
  ];
}
