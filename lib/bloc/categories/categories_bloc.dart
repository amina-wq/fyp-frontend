import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/categories/categories_repository_interface.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesRepositoryInterface _categoriesRepository;

  CategoriesBloc({required CategoriesRepositoryInterface categoriesRepository})
    : _categoriesRepository = categoriesRepository,
      super(const CategoriesInitial()) {
    on<CategoriesLoadRequested>(_onCategoriesLoadRequested);
  }

  Future<void> _onCategoriesLoadRequested(
    CategoriesLoadRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesLoading());

    try {
      final categories = await _categoriesRepository.getCategories();

      emit(CategoriesLoaded(categories: categories));
    } catch (error) {
      emit(
        CategoriesFailure(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
