// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: States for the recipes bloc.
// First Written on: Tuesday, 30-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import '../../models/recipes/recipes.dart';

abstract class RecipesState {
  const RecipesState();
}

class RecipesInitial extends RecipesState {
  const RecipesInitial();
}

class RecipesLoading extends RecipesState {
  const RecipesLoading();
}

class RecipesLoaded extends RecipesState {
  final List<RecipeSummaryModel> recipes;

  const RecipesLoaded({required this.recipes});
}

class RecipesFailure extends RecipesState {
  final String message;

  const RecipesFailure({required this.message});
}
