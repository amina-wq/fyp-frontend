import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/inventory/inventory_repository_interface.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepositoryInterface _inventoryRepository;

  InventoryBloc({
    required InventoryRepositoryInterface inventoryRepository,
  })  : _inventoryRepository = inventoryRepository,
        super(const InventoryInitial()) {
    on<InventoryLoadRequested>(_onLoadRequested);
    on<InventoryFilterChanged>(_onFilterChanged);
    on<InventoryItemCreateRequested>(_onItemCreateRequested);
    on<InventoryItemUpdateRequested>(_onItemUpdateRequested);
    on<InventoryItemImageUploadRequested>(_onItemImageUploadRequested);
    on<InventoryItemImageDeleteRequested>(_onItemImageDeleteRequested);
    on<InventoryItemConsumeRequested>(_onItemConsumeRequested);
    on<InventoryItemWasteRequested>(_onItemWasteRequested);
    on<InventoryItemDeleteRequested>(_onItemDeleteRequested);
  }

  Future<void> _onLoadRequested(
      InventoryLoadRequested event,
      Emitter<InventoryState> emit,
      ) async {
    emit(const InventoryLoadInProgress());

    await _loadInventory(
      emit: emit,
      category: null,
      expiryState: null,
    );
  }

  Future<void> _onFilterChanged(
      InventoryFilterChanged event,
      Emitter<InventoryState> emit,
      ) async {
    final currentState = state;

    if (currentState is InventoryLoadSuccess) {
      emit(
        InventoryActionInProgress(
          items: currentState.items,
          stats: currentState.stats,
          selectedCategory: event.category,
          selectedExpiryState: event.expiryState,
        ),
      );
    } else {
      emit(const InventoryLoadInProgress());
    }

    await _loadInventory(
      emit: emit,
      category: event.category,
      expiryState: event.expiryState,
    );
  }

  Future<void> _onItemCreateRequested(
      InventoryItemCreateRequested event,
      Emitter<InventoryState> emit,
      ) async {
    await _runActionAndReload(
      emit: emit,
      action: () async {
        var createdItem = await _inventoryRepository.createInventoryItem(
          event.data,
        );

        final imagePath = event.imagePath;

        if (imagePath != null && imagePath.isNotEmpty) {
          createdItem = await _inventoryRepository.uploadInventoryItemImage(
            itemId: createdItem.id,
            imagePath: imagePath,
          );
        }

        return createdItem;
      },
    );
  }

  Future<void> _onItemUpdateRequested(
      InventoryItemUpdateRequested event,
      Emitter<InventoryState> emit,
      ) async {
    await _runActionAndReload(
      emit: emit,
      action: () => _inventoryRepository.updateInventoryItem(
        itemId: event.itemId,
        data: event.data,
      ),
    );
  }


  Future<void> _onItemImageUploadRequested(
      InventoryItemImageUploadRequested event,
      Emitter<InventoryState> emit,
      ) async {
    await _runActionAndReload(
      emit: emit,
      action: () => _inventoryRepository.uploadInventoryItemImage(
        itemId: event.itemId,
        imagePath: event.imagePath,
      ),
    );
  }

  Future<void> _onItemImageDeleteRequested(
      InventoryItemImageDeleteRequested event,
      Emitter<InventoryState> emit,
      ) async {
    await _runActionAndReload(
      emit: emit,
      action: () => _inventoryRepository.deleteInventoryItemImage(event.itemId),
    );
  }


  Future<void> _onItemConsumeRequested(
      InventoryItemConsumeRequested event,
      Emitter<InventoryState> emit,
      ) async {
    await _runActionAndReload(
      emit: emit,
      action: () => _inventoryRepository.consumeInventoryItem(event.itemId),
    );
  }

  Future<void> _onItemWasteRequested(
      InventoryItemWasteRequested event,
      Emitter<InventoryState> emit,
      ) async {
    await _runActionAndReload(
      emit: emit,
      action: () => _inventoryRepository.wasteInventoryItem(event.itemId),
    );
  }

  Future<void> _onItemDeleteRequested(
      InventoryItemDeleteRequested event,
      Emitter<InventoryState> emit,
      ) async {
    await _runActionAndReload(
      emit: emit,
      action: () => _inventoryRepository.deleteInventoryItem(event.itemId),
    );
  }

  Future<void> _loadInventory({
    required Emitter<InventoryState> emit,
    required String? category,
    required String? expiryState,
  }) async {
    try {
      final items = await _inventoryRepository.getInventoryItems(
        category: category,
        expiryState: expiryState,
      );

      final stats = await _inventoryRepository.getInventoryStats();

      emit(
        InventoryLoadSuccess(
          items: items,
          stats: stats,
          selectedCategory: category,
          selectedExpiryState: expiryState,
        ),
      );
    } catch (error) {
      emit(
        InventoryFailure(
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> _runActionAndReload({
    required Emitter<InventoryState> emit,
    required Future<Object?> Function() action,
  }) async {
    final currentState = state;

    String? category;
    String? expiryState;

    if (currentState is InventoryLoadSuccess) {
      category = currentState.selectedCategory;
      expiryState = currentState.selectedExpiryState;

      emit(
        InventoryActionInProgress(
          items: currentState.items,
          stats: currentState.stats,
          selectedCategory: category,
          selectedExpiryState: expiryState,
        ),
      );
    } else if (currentState is InventoryActionInProgress) {
      category = currentState.selectedCategory;
      expiryState = currentState.selectedExpiryState;
    }

    try {
      await action();

      await _loadInventory(
        emit: emit,
        category: category,
        expiryState: expiryState,
      );
    } catch (error) {
      emit(
        InventoryFailure(
          message: error.toString(),
        ),
      );
    }
  }
}