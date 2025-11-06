import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/data/constants/default_categories.dart';
import 'package:frontend/data/models/category_model.dart';
import 'package:frontend/views/components/primary_button.dart';
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? _selectedCategory;

  final List<CategoryModel> categories = defaultCategories;

  Color darken(Color color, [double amount = .2]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return hslDark.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 15),
          GridView.builder(
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
                            ? Border.all(color: darken(category.color, 0.25),width: 3)
                            : null,
                        ),
                        child: SvgPicture.asset(
                          category.svgPath,
                          width: 28,
                          height: 28,
                          colorFilter: ColorFilter.mode( darken(category.color, 0.5), BlendMode.srcIn,
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
          const SizedBox(height: 40),
          // BUTTONS 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.deepPurpleAccent)),
              ),
              PrimaryButton(
                onPressed: () {
                  Navigator.pop(context, _selectedCategory);
                },
                text: 'Choose Time',
              )
            ],
          )
        ],
      ),
    ) ;
  }
}