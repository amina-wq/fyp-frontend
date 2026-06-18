class ApiConstants {
  static const String serverUrl = 'http://192.168.1.4';
  static const String baseUrl = '$serverUrl/api/v1';

  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String refreshEndpoint = '/auth/refresh';
  static const String meEndpoint = '/auth/me';

  static String productByBarcodeEndpoint(String barcode) {
    return '/products/barcode/$barcode';
  }

  static String productByIdEndpoint(String productId) {
    return '/products/$productId';
  }

  static const String manualProductEndpoint = '/products/manual';

  static const String inventoryEndpoint = '/inventory';
  static const String inventoryStatsEndpoint = '/inventory/stats';

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