import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyp_frontend/core/network/api_client.dart';
import 'package:fyp_frontend/core/notifications/fcm_service.dart';
import 'package:fyp_frontend/core/storage/token_storage.dart';
import 'package:fyp_frontend/main.dart';
import 'package:fyp_frontend/repositories/repositories.dart';
import 'package:fyp_frontend/router/router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FoodTrack app starts', (WidgetTester tester) async {
    FlutterSecureStorage.setMockInitialValues({});

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

    final recipesRepository = RecipesRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

    final categoriesRepository = CategoriesRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

    final fcmService = FcmService(
      authRepository: authRepository,
    );

    final appRouter = AppRouter(
      authRepository: authRepository,
    );

    await tester.pumpWidget(
      FoodTrackApp(
        apiClient: apiClient,
        tokenStorage: tokenStorage,
        authRepository: authRepository,
        productRepository: productRepository,
        inventoryRepository: inventoryRepository,
        shoppingListRepository: shoppingListRepository,
        recipesRepository: recipesRepository,
        categoriesRepository: categoriesRepository,
        fcmService: fcmService,
        appRouter: appRouter,
      ),
    );

    await tester.pump();

    expect(find.byType(FoodTrackApp), findsOneWidget);
  });
}