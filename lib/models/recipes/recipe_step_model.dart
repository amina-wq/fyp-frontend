// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Recipe preparation step data model.
// First Written on: Tuesday, 30-Jun-2026
// Edited on: Sunday, 12-Jul-2026
class RecipeStepModel {
  final int number;
  final String step;

  const RecipeStepModel({required this.number, required this.step});

  factory RecipeStepModel.fromJson(Map<String, dynamic> json) {
    return RecipeStepModel(
      number: json['number'] as int,
      step: json['step'] as String,
    );
  }
}
