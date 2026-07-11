import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import 'bloc/bloc.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'repositories/repositories.dart';
import 'core/notifications/fcm_service.dart';
import 'router/router.dart';
import 'ui/ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.background,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final apiClient = ApiClient();
  final tokenStorage = TokenStorage();

  final authRepository = AuthRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final fcmService = FcmService(
    authRepository: authRepository,
  );

  final productRepository = ProductRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final inventoryRepository = InventoryRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final shoppingListRepository = ShoppingListRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final recipesRepository = RecipesRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final categoriesRepository = CategoriesRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  final appRouter = AppRouter(
    authRepository: authRepository,
  );

  await fcmService.initialize();

  runApp(
    FoodTrackApp(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
      authRepository: authRepository,
      productRepository: productRepository,
      inventoryRepository: inventoryRepository,
      shoppingListRepository: shoppingListRepository,
      recipesRepository: recipesRepository,
      categoriesRepository: categoriesRepository,
      appRouter: appRouter,
      fcmService: fcmService,
    ),
  );
}

class FoodTrackApp extends StatelessWidget {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  final AuthRepositoryInterface authRepository;
  final ProductRepositoryInterface productRepository;
  final InventoryRepositoryInterface inventoryRepository;
  final ShoppingListRepositoryInterface shoppingListRepository;
  final RecipesRepositoryInterface recipesRepository;
  final CategoriesRepositoryInterface categoriesRepository;
  final AppRouter appRouter;
  final FcmService fcmService;

  const FoodTrackApp({
    super.key,
    required this.apiClient,
    required this.tokenStorage,
    required this.authRepository,
    required this.productRepository,
    required this.inventoryRepository,
    required this.shoppingListRepository,
    required this.recipesRepository,
    required this.categoriesRepository,
    required this.appRouter,
    required this.fcmService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>.value(
          value: apiClient,
        ),
        RepositoryProvider<TokenStorage>.value(
          value: tokenStorage,
        ),
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
        RepositoryProvider<FcmService>.value(
          value: fcmService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepositoryInterface>(),
              fcmService: context.read<FcmService>(),
            ),
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
              shoppingListRepository: context.read<ShoppingListRepositoryInterface>(),
            ),
          ),
          BlocProvider<RecipesBloc>(
            create: (context) => RecipesBloc(
              recipesRepository: context.read<RecipesRepositoryInterface>(),
            ),
          ),
          BlocProvider<CategoriesBloc>(
            create: (context) => CategoriesBloc(
              categoriesRepository: context.read<CategoriesRepositoryInterface>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'FoodTrack',
          debugShowCheckedModeBanner: false,
          theme: themeData,
          routerConfig: appRouter.config(),
        ),
      ),
    );
  }
}