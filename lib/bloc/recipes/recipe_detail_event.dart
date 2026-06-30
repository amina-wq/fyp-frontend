abstract class RecipeDetailEvent {
  const RecipeDetailEvent();
}

class RecipeDetailLoadRequested extends RecipeDetailEvent {
  final int spoonacularId;

  const RecipeDetailLoadRequested({
    required this.spoonacularId,
  });
}