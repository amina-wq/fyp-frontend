// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: App entry point wiring dependencies and launching the widget tree.
// First Written on: Tuesday, 19-May-2026
// Edited on: Friday, 17-Jul-2026
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import 'bloc/bloc.dart';
import 'core/network/api_client.dart';
import 'core/network/authenticated_api_client.dart';
import 'core/notifications/fcm_service.dart';
import 'core/storage/token_storage.dart';
import 'repositories/repositories.dart';
import 'router/router.dart';
import 'ui/ui.dart';

Future<void> main() async {
  await runZonedGuarded(_bootstrap, (error, stackTrace) {
    developer.log(
      'Uncaught zone error',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log(
      'Uncaught Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
      level: 1000,
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    developer.log(
      'Uncaught platform error',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
    return true;
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final apiClient = ApiClient();
  final tokenStorage = TokenStorage();

  final authenticatedApiClient = AuthenticatedApiClient(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final authRepository = AuthRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final fcmService = FcmService(authRepository: authRepository);

  final productRepository = ProductRepository(
    apiClient: authenticatedApiClient,
  );

  final inventoryRepository = InventoryRepository(
    apiClient: authenticatedApiClient,
  );

  final shoppingListRepository = ShoppingListRepository(
    apiClient: authenticatedApiClient,
  );

  final recipesRepository = RecipesRepository(
    apiClient: authenticatedApiClient,
  );

  final categoriesRepository = CategoriesRepository(
    apiClient: authenticatedApiClient,
  );

  final storageRecommendationRepository = StorageRecommendationRepository(
    apiClient: authenticatedApiClient,
  );

  final appRouter = AppRouter(authRepository: authRepository);

  await fcmService.initialize();

  runApp(
    FoodTrackApp(
      apiClient: apiClient,
      authenticatedApiClient: authenticatedApiClient,
      tokenStorage: tokenStorage,
      authRepository: authRepository,
      productRepository: productRepository,
      inventoryRepository: inventoryRepository,
      shoppingListRepository: shoppingListRepository,
      recipesRepository: recipesRepository,
      categoriesRepository: categoriesRepository,
      storageRecommendationRepository: storageRecommendationRepository,
      appRouter: appRouter,
      fcmService: fcmService,
    ),
  );
}

class FoodTrackApp extends StatelessWidget {
  final ApiClient apiClient;
  final AuthenticatedApiClient authenticatedApiClient;
  final TokenStorage tokenStorage;
  final AuthRepositoryInterface authRepository;
  final ProductRepositoryInterface productRepository;
  final InventoryRepositoryInterface inventoryRepository;
  final ShoppingListRepositoryInterface shoppingListRepository;
  final RecipesRepositoryInterface recipesRepository;
  final CategoriesRepositoryInterface categoriesRepository;
  final StorageRecommendationRepositoryInterface
  storageRecommendationRepository;
  final AppRouter appRouter;
  final FcmService fcmService;

  const FoodTrackApp({
    super.key,
    required this.apiClient,
    required this.authenticatedApiClient,
    required this.tokenStorage,
    required this.authRepository,
    required this.productRepository,
    required this.inventoryRepository,
    required this.shoppingListRepository,
    required this.recipesRepository,
    required this.categoriesRepository,
    required this.storageRecommendationRepository,
    required this.appRouter,
    required this.fcmService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>.value(value: apiClient),
        RepositoryProvider<AuthenticatedApiClient>.value(
          value: authenticatedApiClient,
        ),
        RepositoryProvider<TokenStorage>.value(value: tokenStorage),
        RepositoryProvider<AuthRepositoryInterface>.value(
          value: authRepository,
        ),
        RepositoryProvider<ProductRepositoryInterface>.value(
          value: productRepository,
        ),
        RepositoryProvider<InventoryRepositoryInterface>.value(
          value: inventoryRepository,
        ),
        RepositoryProvider<ShoppingListRepositoryInterface>.value(
          value: shoppingListRepository,
        ),
        RepositoryProvider<RecipesRepositoryInterface>.value(
          value: recipesRepository,
        ),
        RepositoryProvider<CategoriesRepositoryInterface>.value(
          value: categoriesRepository,
        ),
        RepositoryProvider<StorageRecommendationRepositoryInterface>.value(
          value: storageRecommendationRepository,
        ),
        RepositoryProvider<FcmService>.value(value: fcmService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepositoryInterface>(),
              fcmService: context.read<FcmService>(),
            )..add(const AuthCheckRequested()),
          ),
          BlocProvider<InventoryBloc>(
            create: (context) => InventoryBloc(
              inventoryRepository: context.read<InventoryRepositoryInterface>(),
            ),
          ),
          BlocProvider<AddManualProductBloc>(
            create: (context) => AddManualProductBloc(
              productRepository: context.read<ProductRepositoryInterface>(),
              inventoryRepository: context.read<InventoryRepositoryInterface>(),
            ),
          ),
          BlocProvider<ScannerBloc>(
            create: (context) => ScannerBloc(
              productRepository: context.read<ProductRepositoryInterface>(),
            ),
          ),
          BlocProvider<ShoppingListBloc>(
            create: (context) => ShoppingListBloc(
              shoppingListRepository: context
                  .read<ShoppingListRepositoryInterface>(),
            ),
          ),
          BlocProvider<RecipesBloc>(
            create: (context) => RecipesBloc(
              recipesRepository: context.read<RecipesRepositoryInterface>(),
            ),
          ),
          BlocProvider<CategoriesBloc>(
            create: (context) => CategoriesBloc(
              categoriesRepository: context
                  .read<CategoriesRepositoryInterface>(),
            ),
          ),
          BlocProvider<StorageRecommendationBloc>(
            create: (context) => StorageRecommendationBloc(
              storageRecommendationRepository: context
                  .read<StorageRecommendationRepositoryInterface>(),
            ),
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final themeMode = _themeModeFromAuthState(authState);

            return MaterialApp.router(
              title: 'FoodTrack',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: appRouter.config(),
              builder: (context, child) {
                final brightness = Theme.of(context).brightness;

                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: _systemUiOverlayStyle(brightness),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

ThemeMode _themeModeFromAuthState(AuthState state) {
  if (state is AuthAuthenticated) {
    return _themeModeFromString(state.user.themeMode);
  }

  if (state is AuthActionInProgress) {
    return _themeModeFromString(state.user.themeMode);
  }

  return ThemeMode.system;
}

ThemeMode _themeModeFromString(String value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

SystemUiOverlayStyle _systemUiOverlayStyle(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    systemNavigationBarColor: isDark
        ? AppThemeColors.dark.background
        : AppThemeColors.light.background,
    systemNavigationBarIconBrightness: isDark
        ? Brightness.light
        : Brightness.dark,
  );
}
