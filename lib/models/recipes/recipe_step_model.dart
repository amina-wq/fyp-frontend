class RecipeStepModel {
  final int number;
  final String step;

  const RecipeStepModel({
    required this.number,
    required this.step,
  });

  factory RecipeStepModel.fromJson(Map<String, dynamic> json) {
    return RecipeStepModel(
      number: json['number'] as int,
      step: json['step'] as String,
    );
  }
}