// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AddManualProductScreen]
class AddManualProductRoute extends PageRouteInfo<AddManualProductRouteArgs> {
  AddManualProductRoute({
    Key? key,
    String? prefilledBarcode,
    List<PageRouteInfo>? children,
  }) : super(
         AddManualProductRoute.name,
         args: AddManualProductRouteArgs(
           key: key,
           prefilledBarcode: prefilledBarcode,
         ),
         initialChildren: children,
       );

  static const String name = 'AddManualProductRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddManualProductRouteArgs>(
        orElse: () => const AddManualProductRouteArgs(),
      );
      return AddManualProductScreen(
        key: args.key,
        prefilledBarcode: args.prefilledBarcode,
      );
    },
  );
}

class AddManualProductRouteArgs {
  const AddManualProductRouteArgs({this.key, this.prefilledBarcode});

  final Key? key;

  final String? prefilledBarcode;

  @override
  String toString() {
    return 'AddManualProductRouteArgs{key: $key, prefilledBarcode: $prefilledBarcode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddManualProductRouteArgs) return false;
    return key == other.key && prefilledBarcode == other.prefilledBarcode;
  }

  @override
  int get hashCode => key.hashCode ^ prefilledBarcode.hashCode;
}

/// generated route for
/// [AddScannedProductScreen]
class AddScannedProductRoute extends PageRouteInfo<AddScannedProductRouteArgs> {
  AddScannedProductRoute({
    Key? key,
    required ProductModel product,
    List<PageRouteInfo>? children,
  }) : super(
         AddScannedProductRoute.name,
         args: AddScannedProductRouteArgs(key: key, product: product),
         initialChildren: children,
       );

  static const String name = 'AddScannedProductRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddScannedProductRouteArgs>();
      return AddScannedProductScreen(key: args.key, product: args.product);
    },
  );
}

class AddScannedProductRouteArgs {
  const AddScannedProductRouteArgs({this.key, required this.product});

  final Key? key;

  final ProductModel product;

  @override
  String toString() {
    return 'AddScannedProductRouteArgs{key: $key, product: $product}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddScannedProductRouteArgs) return false;
    return key == other.key && product == other.product;
  }

  @override
  int get hashCode => key.hashCode ^ product.hashCode;
}

/// generated route for
/// [AuthScreen]
class AuthRoute extends PageRouteInfo<void> {
  const AuthRoute({List<PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthScreen();
    },
  );
}

/// generated route for
/// [EditInventoryItemScreen]
class EditInventoryItemRoute extends PageRouteInfo<EditInventoryItemRouteArgs> {
  EditInventoryItemRoute({
    Key? key,
    required InventoryItemModel item,
    List<PageRouteInfo>? children,
  }) : super(
         EditInventoryItemRoute.name,
         args: EditInventoryItemRouteArgs(key: key, item: item),
         initialChildren: children,
       );

  static const String name = 'EditInventoryItemRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditInventoryItemRouteArgs>();
      return EditInventoryItemScreen(key: args.key, item: args.item);
    },
  );
}

class EditInventoryItemRouteArgs {
  const EditInventoryItemRouteArgs({this.key, required this.item});

  final Key? key;

  final InventoryItemModel item;

  @override
  String toString() {
    return 'EditInventoryItemRouteArgs{key: $key, item: $item}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditInventoryItemRouteArgs) return false;
    return key == other.key && item == other.item;
  }

  @override
  int get hashCode => key.hashCode ^ item.hashCode;
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [InventoryItemDetailsScreen]
class InventoryItemDetailsRoute
    extends PageRouteInfo<InventoryItemDetailsRouteArgs> {
  InventoryItemDetailsRoute({
    Key? key,
    required InventoryItemModel item,
    List<PageRouteInfo>? children,
  }) : super(
         InventoryItemDetailsRoute.name,
         args: InventoryItemDetailsRouteArgs(key: key, item: item),
         initialChildren: children,
       );

  static const String name = 'InventoryItemDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InventoryItemDetailsRouteArgs>();
      return InventoryItemDetailsScreen(key: args.key, item: args.item);
    },
  );
}

class InventoryItemDetailsRouteArgs {
  const InventoryItemDetailsRouteArgs({this.key, required this.item});

  final Key? key;

  final InventoryItemModel item;

  @override
  String toString() {
    return 'InventoryItemDetailsRouteArgs{key: $key, item: $item}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InventoryItemDetailsRouteArgs) return false;
    return key == other.key && item == other.item;
  }

  @override
  int get hashCode => key.hashCode ^ item.hashCode;
}

/// generated route for
/// [RecipeDetailScreen]
class RecipeDetailRoute extends PageRouteInfo<RecipeDetailRouteArgs> {
  RecipeDetailRoute({
    Key? key,
    required int spoonacularId,
    List<PageRouteInfo>? children,
  }) : super(
         RecipeDetailRoute.name,
         args: RecipeDetailRouteArgs(key: key, spoonacularId: spoonacularId),
         initialChildren: children,
       );

  static const String name = 'RecipeDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RecipeDetailRouteArgs>();
      return RecipeDetailScreen(
        key: args.key,
        spoonacularId: args.spoonacularId,
      );
    },
  );
}

class RecipeDetailRouteArgs {
  const RecipeDetailRouteArgs({this.key, required this.spoonacularId});

  final Key? key;

  final int spoonacularId;

  @override
  String toString() {
    return 'RecipeDetailRouteArgs{key: $key, spoonacularId: $spoonacularId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RecipeDetailRouteArgs) return false;
    return key == other.key && spoonacularId == other.spoonacularId;
  }

  @override
  int get hashCode => key.hashCode ^ spoonacularId.hashCode;
}

/// generated route for
/// [RecipesScreen]
class RecipesRoute extends PageRouteInfo<void> {
  const RecipesRoute({List<PageRouteInfo>? children})
    : super(RecipesRoute.name, initialChildren: children);

  static const String name = 'RecipesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RecipesScreen();
    },
  );
}

/// generated route for
/// [ScannerScreen]
class ScannerRoute extends PageRouteInfo<void> {
  const ScannerRoute({List<PageRouteInfo>? children})
    : super(ScannerRoute.name, initialChildren: children);

  static const String name = 'ScannerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ScannerScreen();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [ShellScreen]
class ShellRoute extends PageRouteInfo<void> {
  const ShellRoute({List<PageRouteInfo>? children})
    : super(ShellRoute.name, initialChildren: children);

  static const String name = 'ShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ShellScreen();
    },
  );
}

/// generated route for
/// [ShoppingScreen]
class ShoppingRoute extends PageRouteInfo<void> {
  const ShoppingRoute({List<PageRouteInfo>? children})
    : super(ShoppingRoute.name, initialChildren: children);

  static const String name = 'ShoppingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ShoppingScreen();
    },
  );
}
