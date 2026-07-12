import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/shopping_list/shopping_list_repository_interface.dart';
import 'shopping_list_event.dart';
import 'shopping_list_state.dart';

class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  final ShoppingListRepositoryInterface _shoppingListRepository;

  ShoppingListBloc({
    required ShoppingListRepositoryInterface shoppingListRepository,
  }) : _shoppingListRepository = shoppingListRepository,
       super(const ShoppingListInitial()) {
    on<ShoppingListLoadRequested>(_onLoadRequested);
    on<ShoppingListItemCreateRequested>(_onCreateRequested);
    on<ShoppingListItemToggleRequested>(_onToggleRequested);
    on<ShoppingListItemDeleteRequested>(_onDeleteRequested);
    on<ShoppingListCheckedClearRequested>(_onClearCheckedRequested);
  }

  Future<void> _onLoadRequested(
    ShoppingListLoadRequested event,
    Emitter<ShoppingListState> emit,
  ) async {
    emit(const ShoppingListLoading());

    try {
      final items = await _shoppingListRepository.getShoppingListItems();

      emit(ShoppingListLoaded(items: items));
    } catch (error) {
      emit(
        ShoppingListFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onCreateRequested(
    ShoppingListItemCreateRequested event,
    Emitter<ShoppingListState> emit,
  ) async {
    try {
      await _shoppingListRepository.createShoppingListItem(event.item);
      final items = await _shoppingListRepository.getShoppingListItems();

      emit(ShoppingListLoaded(items: items));
    } catch (error) {
      emit(
        ShoppingListFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onToggleRequested(
    ShoppingListItemToggleRequested event,
    Emitter<ShoppingListState> emit,
  ) async {
    try {
      await _shoppingListRepository.toggleShoppingListItem(event.itemId);
      final items = await _shoppingListRepository.getShoppingListItems();

      emit(ShoppingListLoaded(items: items));
    } catch (error) {
      emit(
        ShoppingListFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    ShoppingListItemDeleteRequested event,
    Emitter<ShoppingListState> emit,
  ) async {
    try {
      await _shoppingListRepository.deleteShoppingListItem(event.itemId);
      final items = await _shoppingListRepository.getShoppingListItems();

      emit(ShoppingListLoaded(items: items));
    } catch (error) {
      emit(
        ShoppingListFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onClearCheckedRequested(
    ShoppingListCheckedClearRequested event,
    Emitter<ShoppingListState> emit,
  ) async {
    try {
      await _shoppingListRepository.clearCheckedItems();
      final items = await _shoppingListRepository.getShoppingListItems();

      emit(ShoppingListLoaded(items: items));
    } catch (error) {
      emit(
        ShoppingListFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
