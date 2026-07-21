// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: States for the storage recommendation bloc.
// First Written on: Tuesday, 14-Jul-2026
// Edited on: Tuesday, 14-Jul-2026
import 'package:equatable/equatable.dart';

import '../../models/storage_recommendation/storage_recommendation.dart';

abstract class StorageRecommendationState extends Equatable {
  const StorageRecommendationState();

  @override
  List<Object?> get props => [];
}

class StorageRecommendationInitial extends StorageRecommendationState {
  const StorageRecommendationInitial();
}

class StorageRecommendationLoading extends StorageRecommendationState {
  const StorageRecommendationLoading();
}

class StorageRecommendationLoaded extends StorageRecommendationState {
  final StorageRecommendationModel recommendation;

  const StorageRecommendationLoaded({required this.recommendation});

  @override
  List<Object?> get props => [recommendation];
}

class StorageRecommendationFailure extends StorageRecommendationState {
  final String message;

  const StorageRecommendationFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
