import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/recipes/recipes_repository_interface.dart';
import 'recipe_detail_event.dart';
import 'recipe_detail_state.dart';

class RecipeDetailBloc extends Bloc<RecipeDetailEvent, RecipeDetailState> {
  final RecipesRepositoryInterface _recipesRepository;

  RecipeDetailBloc({
    required RecipesRepositoryInterface recipesRepository,
  })  : _recipesRepository = recipesRepository,
        super(const RecipeDetailInitial()) {
    on<RecipeDetailLoadRequested>(_onRecipeDetailLoadRequested);
  }

  Future<void> _onRecipeDetailLoadRequested(
      RecipeDetailLoadRequested event,
      Emitter<RecipeDetailState> emit,
      ) async {
    emit(const RecipeDetailLoading());

    try {
      final recipe = await _recipesRepository.getRecipeDetails(
        spoonacularId: event.spoonacularId,
      );

      emit(
        RecipeDetailLoaded(
          recipe: recipe,
        ),
      );
    } catch (error) {
      emit(
        RecipeDetailFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}