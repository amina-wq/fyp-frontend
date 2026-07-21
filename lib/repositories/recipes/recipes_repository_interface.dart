// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Abstract interface for the recipes repository.
// First Written on: Tuesday, 19-May-2026
// Edited on: Sunday, 12-Jul-2026
import '../../models/recipes/recipes.dart';

abstract class RecipesRepositoryInterface {
  Future<List<RecipeSummaryModel>> getRecipesByInventory({int number = 10});

  Future<RecipeDetailModel> getRecipeDetails({required int spoonacularId});
}
