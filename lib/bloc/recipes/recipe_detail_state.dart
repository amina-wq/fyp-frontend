// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: States for the recipe detail bloc.
// First Written on: Tuesday, 30-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import '../../models/recipes/recipes.dart';

abstract class RecipeDetailState {
  const RecipeDetailState();
}

class RecipeDetailInitial extends RecipeDetailState {
  const RecipeDetailInitial();
}

class RecipeDetailLoading extends RecipeDetailState {
  const RecipeDetailLoading();
}

class RecipeDetailLoaded extends RecipeDetailState {
  final RecipeDetailModel recipe;

  const RecipeDetailLoaded({required this.recipe});
}

class RecipeDetailFailure extends RecipeDetailState {
  final String message;

  const RecipeDetailFailure({required this.message});
}
