// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: States for the categories bloc.
// First Written on: Friday, 03-Jul-2026
// Edited on: Sunday, 12-Jul-2026
import '../../models/categories/categories.dart';

abstract class CategoriesState {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryModel> categories;

  const CategoriesLoaded({required this.categories});
}

class CategoriesFailure extends CategoriesState {
  final String message;

  const CategoriesFailure({required this.message});
}
