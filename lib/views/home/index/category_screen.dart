import 'package:flutter/material.dart';
import 'package:frontend/views/components/primary_button.dart';
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? selectedCategory;

  final List<Map<String, dynamic>> listCategory = [
    {
      'label': 'Grocery',
      'color': const Color(0xFFCCFF80),
      'icon': Icons.local_grocery_store,
    },
    {
      'label': 'Work',
      'color': const Color(0xFFFF9680),
      'icon': Icons.work,
    },
    {
      'label': 'Sport',
      'color': const Color(0xFF80FFFF),
      'icon': Icons.fitness_center,
    },
    {
      'label': 'Design',
      'color': const Color(0xFF80FFD9),
      'icon': Icons.design_services,
    },
    {
      'label': 'University',
      'color': const Color(0xFF809CFF),
      'icon': Icons.school,
    },
    {
      'label': 'Social',
      'color': const Color(0xFFFF80EB),
      'icon': Icons.campaign,
    },
    {
      'label': 'Music',
      'color': const Color(0xFFFC80FF),
      'icon': Icons.music_note,
    },
    {
      'label': 'Health',
      'color': const Color(0xFF80FFA3),
      'icon': Icons.favorite,
    },
    {
      'label': 'Movie',
      'color': const Color(0xFF80D1FF),
      'icon': Icons.movie,
    },
  ];

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
            itemCount: listCategory.length,
            itemBuilder: (context, index ) {
              final category = listCategory[index];
              final isSelected = selectedCategory == category['label'];
              return GestureDetector(
                onTap:() {
                  setState(() {
                    selectedCategory = category['label'];
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
                          color: category['color'],
                          borderRadius: BorderRadius.circular(4),
                          border: isSelected
                            ? Border.all(color: darken(category['color'], 0.25),width: 3)
                            : null,
                        ),
                        child: Icon(
                          category['icon'],
                          color: darken(category['color'], 0.5),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      category['label'],
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
                  Navigator.pop(context);
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