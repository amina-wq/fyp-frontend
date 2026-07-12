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
