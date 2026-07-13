import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/storage_recommendation/storage_recommendation.dart';
import '../../repositories/storage_recommendations/storage_recommendation_repository_interface.dart';
import 'storage_recommendation_event.dart';
import 'storage_recommendation_state.dart';

class StorageRecommendationBloc
    extends Bloc<StorageRecommendationEvent, StorageRecommendationState> {
  final StorageRecommendationRepositoryInterface _storageRecommendationRepository;

  StorageRecommendationBloc({
    required StorageRecommendationRepositoryInterface
    storageRecommendationRepository,
  }) : _storageRecommendationRepository = storageRecommendationRepository,
       super(const StorageRecommendationInitial()) {
    on<StorageRecommendationRequested>(_onRequested);
    on<StorageRecommendationCleared>(_onCleared);
  }

  Future<void> _onRequested(
    StorageRecommendationRequested event,
    Emitter<StorageRecommendationState> emit,
  ) async {
    emit(const StorageRecommendationLoading());

    try {
      final recommendation = await _storageRecommendationRepository
          .getRecommendation(
            StorageRecommendationRequestModel(
              name: event.name,
              category: event.category,
            ),
          );

      emit(StorageRecommendationLoaded(recommendation: recommendation));
    } catch (error) {
      emit(
        StorageRecommendationFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onCleared(
    StorageRecommendationCleared event,
    Emitter<StorageRecommendationState> emit,
  ) {
    emit(const StorageRecommendationInitial());
  }
}
