import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mvvm/viewmodels/task/task_cubit.dart';

class TaskChart extends StatefulWidget {
  final String filterType;

  const TaskChart({super.key, required this.filterType});

  @override
  State<TaskChart> createState() => _TaskChartState();
}

class _TaskChartState extends State<TaskChart> {
  late PageController _pageController;
  final int _initialPage = 1000; // Để có thể vuốt về quá khứ thoải mái
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = _initialPage;
    _pageController = PageController(initialPage: _initialPage);
  }

  // Hàm tính toán ngày mốc dựa trên index của trang
  DateTime _getPivotDate(int index) {
    DateTime now = DateTime.now();
    int offset = index - _initialPage;

    if (widget.filterType == 'Week') {
      return now.add(Duration(days: offset * 7));
    } else if (widget.filterType == 'Month') {
      return DateTime(now.year, now.month + offset, 1);
    } else {
      return DateTime(now.year + offset, 1, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hiển thị tiêu đề khoảng thời gian hiện tại của trang đang xem
        _buildTimeIndicator(),
        const SizedBox(height: 10),
        SizedBox(
          height: 250, // Tăng chiều cao để đủ chỗ cho tiêu đề 2 dòng
          child: PageView.builder(
            controller: _pageController,
            itemCount: _initialPage + 1,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final pivotDate = _getPivotDate(index);
              final chartData = context.read<TaskCubit>().getTaskAnalyticsCustom(widget.filterType, pivotDate);

              return _buildBarChart(chartData, pivotDate);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeIndicator() {
    final date = _getPivotDate(_currentPage);
    String label = "";

    if (widget.filterType == 'Week') {
      // Tìm ngày Thứ 2 và Chủ nhật của tuần đó
      DateTime mon = date.subtract(Duration(days: date.weekday - 1));
      DateTime sun = date.add(Duration(days: 7 - date.weekday));
      
      // Định dạng: DD/MM - DD/MM (YYYY)
      label = "${mon.day}/${mon.month} - ${sun.day}/${sun.month} (${date.year})";
    } 
    else if (widget.filterType == 'Month') {
      // Danh sách tên các tháng tiếng Anh
      const monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];
      // label = "Tháng 1, 2024" -> "January, 2024"
      label = "${monthNames[date.month - 1]}, ${date.year}";
    } 
    else {
      // label = "Năm 2024" -> "Year 2024" hoặc chỉ hiện "2024"
      label = "Year ${date.year}";
    }

    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF8687E7), 
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildBarChart(Map<int, int> chartData, DateTime pivotDate) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF363636),
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(chartData),
          barGroups: _buildBarGroups(chartData),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45, // Không gian cho 2 dòng text
                getTitlesWidget: (val, meta) => _getBottomTitles(val, meta, pivotDate),
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

  double _getMaxY(Map<int, int> data) {
    int max = 0;
    data.forEach((_, value) { if (value > max) max = value; });
    return max == 0 ? 5 : (max + 2).toDouble();
  }

  List<BarChartGroupData> _buildBarGroups(Map<int, int> data) {
    return data.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: const Color(0xFF8687E7),
            width: widget.filterType == 'Week' ? 14 : (widget.filterType == 'Month' ? 4 : 12),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  Widget _getBottomTitles(double value, TitleMeta meta, DateTime pivotDate) {
    String topText = '';
    String bottomText = '';

    if (widget.filterType == 'Week') {
      const days = ['', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      topText = days[value.toInt()];
      // Tính ngày của cột này
      DateTime mon = pivotDate.subtract(Duration(days: pivotDate.weekday - 1));
      DateTime currentDay = mon.add(Duration(days: value.toInt() - 1));
      bottomText = "${currentDay.day}/${currentDay.month}";
    } 
    else if (widget.filterType == 'Month') {
      if (value % 5 == 0 || value == 1) topText = value.toInt().toString();
    } 
    else {
      if (value % 2 != 0) topText = 'M${value.toInt()}';
    }

    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Column(
        children: [
          Text(topText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          if (bottomText.isNotEmpty)
            Text(bottomText, style: const TextStyle(color: Colors.grey, fontSize: 8)),
        ],
      ),
    );
  }
}