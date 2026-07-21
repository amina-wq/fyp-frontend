// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Events for the storage recommendation bloc.
// First Written on: Tuesday, 14-Jul-2026
// Edited on: Tuesday, 14-Jul-2026
import 'package:equatable/equatable.dart';

abstract class StorageRecommendationEvent extends Equatable {
  const StorageRecommendationEvent();

  @override
  List<Object?> get props => [];
}

class StorageRecommendationRequested extends StorageRecommendationEvent {
  final String name;
  final String? category;

  const StorageRecommendationRequested({required this.name, this.category});

  @override
  List<Object?> get props => [name, category];
}

class StorageRecommendationCleared extends StorageRecommendationEvent {
  const StorageRecommendationCleared();
}
