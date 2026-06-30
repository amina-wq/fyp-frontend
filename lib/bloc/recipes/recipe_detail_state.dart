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

  const RecipeDetailLoaded({
    required this.recipe,
  });
}

class RecipeDetailFailure extends RecipeDetailState {
  final String message;

  const RecipeDetailFailure({
    required this.message,
  });
}