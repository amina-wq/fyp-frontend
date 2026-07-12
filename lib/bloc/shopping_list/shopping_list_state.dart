import '../../models/shopping_list/shopping_list.dart';

abstract class ShoppingListState {
  const ShoppingListState();
}

class ShoppingListInitial extends ShoppingListState {
  const ShoppingListInitial();
}

class ShoppingListLoading extends ShoppingListState {
  const ShoppingListLoading();
}

class ShoppingListLoaded extends ShoppingListState {
  final List<ShoppingListItemModel> items;

  const ShoppingListLoaded({required this.items});

  List<ShoppingListItemModel> get uncheckedItems {
    return items.where((item) => !item.isChecked).toList();
  }

  List<ShoppingListItemModel> get checkedItems {
    return items.where((item) => item.isChecked).toList();
  }
}

class ShoppingListFailure extends ShoppingListState {
  final String message;

  const ShoppingListFailure({required this.message});
}
