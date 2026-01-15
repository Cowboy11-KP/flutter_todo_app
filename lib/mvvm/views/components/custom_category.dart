import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/datasources/constants/default_categories.dart';
import 'package:frontend/mvvm/models/category/category_model.dart';
import 'package:frontend/theme/app_color.dart';
import 'package:frontend/mvvm/views/components/primary_button.dart';
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? _selectedCategory;

  final List<CategoryModel> categories = defaultCategories;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF363636),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Category',
           style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10,),
          // Divider
          const Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.all(15),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 49,
                mainAxisSpacing: 42,
                childAspectRatio: 0.7
              ),
              itemCount: categories.length,
              itemBuilder: (context, index ) {
                final category = categories[index];
                final isSelected = _selectedCategory == category.label;
                return GestureDetector(
                  onTap:() {
                    setState(() {
                      _selectedCategory = category.label;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: category.color,
                            borderRadius: BorderRadius.circular(4),
                            border: isSelected
                              ? Border.all(color: AppColors.darken(category.color, 0.25), width: 3)
                              : null,
                            boxShadow: [
                              if (isSelected) 
                                BoxShadow(
                                  color: AppColors.darken(category.color, 0.25),
                                  offset: const Offset(0, 4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                          ),
                          child: SvgPicture.asset(
                            category.svgPath,
                            width: 28,
                            height: 28,
                            colorFilter: ColorFilter.mode(AppColors.darken(category.color, 0.5), BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        category.label,
                        style: Theme.of(context).textTheme.bodySmall,maxLines: 1, overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          // BUTTONS 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith
                    (color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ), 
              const SizedBox(width: 15),
              Expanded(
                flex: 1,
                child: PrimaryButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedCategory);
                  },
                  text: 'Choose',
                ),
              )
            ],
          )
        ],
      ),
    ) ;
  }
}