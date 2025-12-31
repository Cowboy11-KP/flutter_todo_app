import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TaskChart extends StatelessWidget {
  final Map<int, int> chartData;
  final String filterType;

  const TaskChart({super.key, required this.chartData, required this.filterType});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF363636),
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barGroups: _buildBarGroups(context),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _getBottomTitles,
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  double _getMaxY() {
    int max = 0;
    chartData.forEach((_, value) { if (value > max) max = value; });
    return (max + 2).toDouble();
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context) {
  // Chuyển Map thành List và sắp xếp theo Key (thứ tự ngày/tháng)
  final sortedEntries = chartData.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  return sortedEntries.map((entry) {
    // Kiểm tra xem value có bị null không
    double barValue = (entry.value).toDouble();
    
    return BarChartGroupData(
      x: entry.key,
      barRods: [
        BarChartRodData(
          toY: barValue,
          color: Theme.of(context).colorScheme.primary,
          width: filterType == 'Week' ? 12 : 4,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }).toList();
}

  Widget _getBottomTitles(double value, TitleMeta meta) {
    String text = '';
    if (filterType == 'Week') {
      switch (value.toInt()) {
        case 1: text = 'MON'; break;
        case 2: text = 'TUE'; break;
        case 3: text = 'WED'; break;
        case 4: text = 'THU'; break;
        case 5: text = 'FRI'; break;
        case 6: text = 'SAT'; break;
        case 7: text = 'SUN'; break;
        default: text = ''; break;
      }
    } else if (filterType == 'Month') {
      if (value % 5 == 0) text = value.toInt().toString(); // Hiện ngày 5, 10, 15...
    } else {
      if (value % 2 != 0) text = 'M${value.toInt()}'; // Hiện tháng 1, 3, 5...
    }
    return SideTitleWidget(meta: meta, child: Text(text, style: TextStyle(color: Colors.white, fontSize: 10)));
  }
}