import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String label;

  @HiveField(1)
  int colorValue;

  @HiveField(2)
  String svgPath; // <-- thay vì iconName

  CategoryModel({
    required this.label,
    required this.colorValue,
    required this.svgPath,
  });

  Color get color => Color(colorValue);
}
