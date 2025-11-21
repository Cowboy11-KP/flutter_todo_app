import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/data/models/task_model.dart';
import 'package:frontend/data/models/category_model.dart';

class HiveConfig {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register all adapters at one place
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());

    // Open all boxes needed in app
    await Hive.openBox<TaskModel>('Tasks');
    await Hive.openBox<CategoryModel>('categories');
  }
}
