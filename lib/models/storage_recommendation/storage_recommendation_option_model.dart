class StorageRecommendationOptionModel {
  final String location;
  final String state;
  final int recommendedDays;
  final int? minDays;
  final int? maxDays;
  final int? bestBeforeDays;

  const StorageRecommendationOptionModel({
    required this.location,
    required this.state,
    required this.recommendedDays,
    this.minDays,
    this.maxDays,
    this.bestBeforeDays,
  });

  factory StorageRecommendationOptionModel.fromJson(Map<String, dynamic> json) {
    return StorageRecommendationOptionModel(
      location: json['location'] as String,
      state: json['state'] as String,
      recommendedDays: json['recommended_days'] as int,
      minDays: json['min_days'] as int?,
      maxDays: json['max_days'] as int?,
      bestBeforeDays: json['best_before_days'] as int?,
    );
  }
}
