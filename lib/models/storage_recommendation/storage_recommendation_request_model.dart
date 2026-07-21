// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Payload model for requesting a storage recommendation.
// First Written on: Tuesday, 14-Jul-2026
// Edited on: Tuesday, 14-Jul-2026
class StorageRecommendationRequestModel {
  final String name;
  final String? category;
  final String? location;
  final String? state;

  const StorageRecommendationRequestModel({
    required this.name,
    this.category,
    this.location,
    this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (state != null) 'state': state,
    };
  }
}
