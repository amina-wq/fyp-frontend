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
