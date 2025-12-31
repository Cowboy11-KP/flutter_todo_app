import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/viewmodels/task_cubit.dart';

class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({super.key});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  // Lưu index của miếng bánh đang được chạm
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final categoryData = context.read<TaskCubit>().getTaskCountByCategory();
    
    if (categoryData.isEmpty) {
      return Container(
        height: 150, width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF363636), 
          borderRadius: BorderRadius.circular(12)
        ),
        child: const Center(
          child: Text("No Data Available", style: TextStyle(color: Colors.grey))
        ),
      );
    }

    int total = categoryData.values.fold(0, (sum, item) => sum + item);
    final List<MapEntry<String, int>> entries = categoryData.entries.toList();

    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF363636), 
        borderRadius: BorderRadius.circular(12)
      ),
      child: PieChart(
        PieChartData(
          // --- BẮT SỰ KIỆN CHẠM ---
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                // Kiểm tra nếu không chạm hoặc nhấc tay ra thì reset index
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                // Lưu lại index miếng bánh đang giữ
                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          sectionsSpace: 3,
          centerSpaceRadius: 35,
          sections: entries.asMap().entries.map((entry) {
            final int index = entry.key;
            final data = entry.value;
            
            // Kiểm tra xem miếng này có đang được chọn hay không
            final isTouched = index == touchedIndex;
            final double percentage = (data.value / total) * 100;

            return PieChartSectionData(
              value: data.value.toDouble(),
              // HIỂN THỊ: Nếu ấn vào thì hiện %, không thì hiện tên Category
              title: isTouched 
                  ? "${percentage.toStringAsFixed(1)}%" 
                  : data.key,
              color: Colors.primaries[index % Colors.primaries.length],
              // Hiệu ứng: Miếng đang chọn sẽ to ra một chút
              radius: isTouched ? 70 : 60,
              titleStyle: TextStyle(
                fontSize: isTouched ? 16 : 12, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
                shadows: isTouched ? [const Shadow(color: Colors.black, blurRadius: 2)] : [],
              ),
              // Đẩy text ra xa tâm một chút để không bị đè chữ
              titlePositionPercentageOffset: 0.55,
            );
          }).toList(),
        ),
      ),
    );
  }
}