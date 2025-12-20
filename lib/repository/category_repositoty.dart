import 'package:frontend/data/constants/default_categories.dart';
import 'package:frontend/data/local/hive_service.dart';
import 'package:frontend/models/category_model.dart';

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
