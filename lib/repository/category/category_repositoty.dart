import 'package:frontend/datasources/constants/default_categories.dart';
import 'package:frontend/datasources/local/hive_service.dart';
import 'package:frontend/mvvm/models/category/category_model.dart';

class CategoryRepository {
  final LocalCategoryService local;

  CategoryRepository({required this.local});

  List<CategoryModel> getAllCategories() {
    final userCategories = local.getAll();
    return [...defaultCategories, ...userCategories];
  }

  Future<void> addCategory(CategoryModel category) async {
    await local.add(category);
  }

  Future<void> deleteCategory(String label) async {
    await local.delete(label);
  }
}
