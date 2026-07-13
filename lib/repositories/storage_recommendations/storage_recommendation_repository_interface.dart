import '../../models/storage_recommendation/storage_recommendation.dart';

abstract class StorageRecommendationRepositoryInterface {
  Future<StorageRecommendationModel> getRecommendation(
    StorageRecommendationRequestModel data,
  );
}
