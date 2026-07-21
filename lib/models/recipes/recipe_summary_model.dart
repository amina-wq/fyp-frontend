// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Recipe summary data model used in recommendation lists.
// First Written on: Tuesday, 30-Jun-2026
// Edited on: Sunday, 12-Jul-2026
class RecipeSummaryModel {
  final int spoonacularId;
  final String title;
  final String? image;
  final double matchScore;
  final int usedIngredientCount;
  final int missedIngredientCount;

  const RecipeSummaryModel({
    required this.spoonacularId,
    required this.title,
    required this.image,
    required this.matchScore,
    required this.usedIngredientCount,
    required this.missedIngredientCount,
  });

  factory RecipeSummaryModel.fromJson(Map<String, dynamic> json) {
    return RecipeSummaryModel(
      spoonacularId: json['spoonacular_id'] as int,
      title: json['title'] as String,
      image: json['image'] as String?,
      matchScore: (json['match_score'] as num).toDouble(),
      usedIngredientCount: json['used_ingredient_count'] as int,
      missedIngredientCount: json['missed_ingredient_count'] as int,
    );
  }
}
