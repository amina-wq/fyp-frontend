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
