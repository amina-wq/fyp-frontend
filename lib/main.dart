import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import 'bloc/bloc.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'repositories/repositories.dart';
import 'repositories/auth/auth_repository_interface.dart';
import 'repositories/inventory/inventory_repository_interface.dart';
import 'repositories/products/product_repository_interface.dart';
import 'repositories/shopping_list/shopping_list_repository_interface.dart';
import 'router/router.dart';
import 'ui/ui.dart';

void main() {
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

  final appRouter = AppRouter(
    authRepository: authRepository,
  );

  runApp(
    FoodTrackApp(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
      authRepository: authRepository,
      productRepository: productRepository,
      inventoryRepository: inventoryRepository,
      shoppingListRepository: shoppingListRepository,
      appRouter: appRouter,
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
  final AppRouter appRouter;

  const FoodTrackApp({
    super.key,
    required this.apiClient,
    required this.tokenStorage,
    required this.authRepository,
    required this.productRepository,
    required this.inventoryRepository,
    required this.shoppingListRepository,
    required this.appRouter,
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepositoryInterface>(),
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