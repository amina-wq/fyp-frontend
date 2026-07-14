import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyp_frontend/core/network/api_client.dart';
import 'package:fyp_frontend/core/network/authenticated_api_client.dart';
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

    final authenticatedApiClient = AuthenticatedApiClient(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

    final authRepository = AuthRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

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

    final fcmService = FcmService(authRepository: authRepository);

    final appRouter = AppRouter(authRepository: authRepository);

    await tester.pumpWidget(
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
        fcmService: fcmService,
        appRouter: appRouter,
      ),
    );

    await tester.pump();

    expect(find.byType(FoodTrackApp), findsOneWidget);
  });
}
