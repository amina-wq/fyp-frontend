import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/recipes/recipes_repository_interface.dart';
import 'recipes_event.dart';
import 'recipes_state.dart';

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  final RecipesRepositoryInterface _recipesRepository;

  RecipesBloc({required RecipesRepositoryInterface recipesRepository})
    : _recipesRepository = recipesRepository,
      super(const RecipesInitial()) {
    on<RecipesLoadRequested>(_onRecipesLoadRequested);
  }

  Future<void> _onRecipesLoadRequested(
    RecipesLoadRequested event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const RecipesLoading());

    try {
      final recipes = await _recipesRepository.getRecipesByInventory(
        number: event.number,
      );

      emit(RecipesLoaded(recipes: recipes));
    } catch (error) {
      emit(
        RecipesFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
