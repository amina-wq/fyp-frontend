import '../../models/categories/categories.dart';

abstract class CategoriesRepositoryInterface {
  Future<List<CategoryModel>> getCategories();
}