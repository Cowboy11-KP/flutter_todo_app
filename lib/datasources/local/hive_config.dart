import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/mvvm/models/task/task_model.dart';
import 'package:frontend/mvvm/models/category/category_model.dart';

class HiveConfig {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register all adapters at one place
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());

    // Open all boxes needed in app
    await Hive.openBox('settings');
    await Hive.openBox<TaskModel>('Tasks');
    await Hive.openBox<CategoryModel>('categories');
  }
}
