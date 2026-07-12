import '../../models/recipes/recipes.dart';

abstract class RecipesRepositoryInterface {
  Future<List<RecipeSummaryModel>> getRecipesByInventory({int number = 10});

  Future<RecipeDetailModel> getRecipeDetails({required int spoonacularId});
}
