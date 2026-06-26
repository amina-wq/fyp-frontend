import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:fyp_frontend/core/network/api_client.dart';
import 'package:fyp_frontend/core/storage/token_storage.dart';
import 'package:fyp_frontend/main.dart';
import 'package:fyp_frontend/repositories/auth/auth_repository.dart';
import 'package:fyp_frontend/repositories/products/product_repository.dart';
import 'package:fyp_frontend/repositories/inventory/inventory_repository.dart';
import 'package:fyp_frontend/repositories/shopping_list/shopping_list_repository.dart';
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

    final shopppingListRepository = ShoppingListRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
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
        shoppingListRepository:shopppingListRepository,
        appRouter: appRouter,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('FoodTrack'), findsWidgets);
  });
}