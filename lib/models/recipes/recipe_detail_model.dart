import 'recipe_ingredient_model.dart';
import 'recipe_step_model.dart';

class RecipeDetailModel {
  final int spoonacularId;
  final String title;
  final String? image;
  final int? readyInMinutes;
  final int? servings;
  final double? calories;
  final List<RecipeIngredientModel> ingredients;
  final List<RecipeStepModel> steps;

  const RecipeDetailModel({
    required this.spoonacularId,
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.servings,
    required this.calories,
    required this.ingredients,
    required this.steps,
  });

  factory RecipeDetailModel.fromJson(Map<String, dynamic> json) {
    final ingredientsData = json['ingredients'] as List<dynamic>;
    final stepsData = json['steps'] as List<dynamic>;

    return RecipeDetailModel(
      spoonacularId: json['spoonacular_id'] as int,
      title: json['title'] as String,
      image: json['image'] as String?,
      readyInMinutes: json['ready_in_minutes'] as int?,
      servings: json['servings'] as int?,
      calories: json['calories'] == null
          ? null
          : (json['calories'] as num).toDouble(),
      ingredients: ingredientsData
          .map(
            (ingredient) => RecipeIngredientModel.fromJson(
              ingredient as Map<String, dynamic>,
            ),
          )
          .toList(),
      steps: stepsData
          .map((step) => RecipeStepModel.fromJson(step as Map<String, dynamic>))
          .toList(),
    );
  }
}
