// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Abstract interface for the categories repository.
// First Written on: Friday, 03-Jul-2026
// Edited on: Sunday, 12-Jul-2026
import '../../models/categories/categories.dart';

abstract class CategoriesRepositoryInterface {
  Future<List<CategoryModel>> getCategories();
}
