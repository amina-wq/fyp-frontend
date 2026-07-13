import 'storage_recommendation_option_model.dart';

class StorageRecommendationModel {
  final String input;
  final String canonicalName;
  final String displayName;
  final String category;
  final int? recommendedDays;
  final int? minDays;
  final int? maxDays;
  final String? location;
  final String? state;
  final String source;
  final double confidence;
  final bool isVerified;
  final bool requiresClarification;
  final List<StorageRecommendationOptionModel> options;

  const StorageRecommendationModel({
    required this.input,
    required this.canonicalName,
    required this.displayName,
    required this.category,
    this.recommendedDays,
    this.minDays,
    this.maxDays,
    this.location,
    this.state,
    required this.source,
    required this.confidence,
    required this.isVerified,
    required this.requiresClarification,
    required this.options,
  });

  factory StorageRecommendationModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];

    return StorageRecommendationModel(
      input: json['input'] as String,
      canonicalName: json['canonical_name'] as String,
      displayName: json['display_name'] as String,
      category: json['category'] as String,
      recommendedDays: json['recommended_days'] as int?,
      minDays: json['min_days'] as int?,
      maxDays: json['max_days'] as int?,
      location: json['location'] as String?,
      state: json['state'] as String?,
      source: json['source'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      isVerified: json['is_verified'] as bool,
      requiresClarification: json['requires_clarification'] as bool,
      options: rawOptions
          .map(
            (option) => StorageRecommendationOptionModel.fromJson(
              option as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
