// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Events for the recipe detail bloc.
// First Written on: Tuesday, 30-Jun-2026
// Edited on: Sunday, 12-Jul-2026
abstract class RecipeDetailEvent {
  const RecipeDetailEvent();
}

class RecipeDetailLoadRequested extends RecipeDetailEvent {
  final int spoonacularId;

  const RecipeDetailLoadRequested({required this.spoonacularId});
}
