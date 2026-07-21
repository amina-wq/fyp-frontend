// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Abstract interface for the storage recommendation repository.
// First Written on: Tuesday, 14-Jul-2026
// Edited on: Tuesday, 14-Jul-2026
import '../../models/storage_recommendation/storage_recommendation.dart';

abstract class StorageRecommendationRepositoryInterface {
  Future<StorageRecommendationModel> getRecommendation(
    StorageRecommendationRequestModel data,
  );
}
