class ApiConstants {
  // static const String serverUrl = 'http://52.77.124.3';
  static const String serverUrl = 'http://192.168.1.2';
  static const String baseUrl = '$serverUrl/api/v1';

  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String refreshEndpoint = '/auth/refresh';
  static const String meEndpoint = '/auth/me';

  static const String fcmTokenEndpoint = '/auth/fcm-token';
  static const String updateNameEndpoint = '/auth/me/name';
  static const String updateSettingsEndpoint = '/auth/me/settings';

  static String productByBarcodeEndpoint(String barcode) {
    return '/products/barcode/$barcode';
  }

  static String productByIdEndpoint(String productId) {
    return '/products/$productId';
  }

  static const String manualProductEndpoint = '/products/manual';

  static const String inventoryEndpoint = '/inventory';
  static const String inventoryStatsEndpoint = '/inventory/stats';

  static const String categoriesEndpoint = '/categories';

  static String inventoryItemByIdEndpoint(String itemId) {
    return '/inventory/$itemId';
  }

  static String inventoryItemImageEndpoint(String itemId) {
    return '/inventory/$itemId/image';
  }

  static String consumeInventoryItemEndpoint(String itemId) {
    return '/inventory/$itemId/consume';
  }

  static String wasteInventoryItemEndpoint(String itemId) {
    return '/inventory/$itemId/waste';
  }

  static const String shoppingListEndpoint = '/shopping-list';

  static String shoppingListItemByIdEndpoint(String itemId) {
    return '/shopping-list/$itemId';
  }

  static String shoppingListItemCheckEndpoint(String itemId) {
    return '/shopping-list/$itemId/check';
  }

  static const String shoppingListCheckedEndpoint = '/shopping-list/checked';

  static const String recipesByIngredientsEndpoint = '/recipes/by-ingredients';

  static String recipeDetailsEndpoint(int spoonacularId) {
    return '/recipes/$spoonacularId';
  }

  static String resolveImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    return '$serverUrl$imageUrl';
  }
}
