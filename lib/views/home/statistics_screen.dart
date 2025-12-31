import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/task_model.dart';
import 'package:frontend/viewmodels/task_cubit.dart';
import 'package:frontend/viewmodels/task_state.dart';
import 'package:frontend/views/components/custom_app_bar.dart';
import 'package:frontend/views/components/task_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedFilter = 'Week';
  bool _isFilterOpen = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: const CustomAppBar(title: 'Statistics', showBack: false,),
        body: BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF8687E7)));
            }

            List<TaskModel> tasks = [];
              if (state is TaskLoaded) {
                tasks = state.tasks;
              } else if (state is TaskActionSuccess) {
                tasks = state.tasks;
              } else {
                // Nếu chưa có data gì cả (TaskInitial chẳng hạn)
                return const Center(child: Text("No data yet", style: TextStyle(color: Colors.white)));
              }
            final completedTasks = tasks.where((t) => t.isDone).length;
            final totalTasks = tasks.length;
            final double completionRate = totalTasks == 0 ? 0 : (completedTasks / totalTasks) * 100;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TIÊU ĐỀ & BỘ LỌC DROPDOWN ---
                  _buildHeaderFilter(),
                  const SizedBox(height: 16),

                  // 1. BIỂU ĐỒ CỘT
                  TaskChart(
                    chartData: context.read<TaskCubit>().getTaskAnalytics(selectedFilter),
                    filterType: selectedFilter,
                  ),

                  const SizedBox(height: 32),

                  // 2. CHỈ SỐ TÓM TẮT (QUICK STATS)
                  const Text("Quick Stats", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMiniCard("Total Tasks", "$totalTasks", Colors.blueAccent),
                      const SizedBox(width: 16),
                      _buildMiniCard("Completed", "$completedTasks", Colors.greenAccent),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCompletionRateCard(completionRate),

                  const SizedBox(height: 32),

                  // 3. BIỂU ĐỒ TRÒN (CATEGORIES)
                  const Text("Categories", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildCategoryPieChart(context),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET HELPER: HEADER CÓ DROPDOWN ---
  Widget _buildHeaderFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$selectedFilter Productivity",
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        PopupMenuButton<String>(
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: const Color(0xFF363636),
          // Logic đổi Icon khi nhấn
          icon: Icon(
            _isFilterOpen ? Icons.keyboard_arrow_down_sharp : Icons.arrow_forward_ios_outlined,
            color: Colors.white,
            size: 20,
          ),
          onOpened: () => setState(() => _isFilterOpen = true),
          onCanceled: () => setState(() => _isFilterOpen = false),
          onSelected: (String value) {
            setState(() {
              selectedFilter = value;
              _isFilterOpen = false;
            });
          },
          itemBuilder: (context) => [
            _buildPopupItem('Week', Icons.calendar_view_week),
            _buildPopupItem('Month', Icons.calendar_month),
            _buildPopupItem('Year', Icons.calendar_today),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8687E7), size: 18),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // --- CÁC WIDGET THÀNH PHẦN KHÁC ---
  Widget _buildMiniCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF363636), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionRateCard(double rate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF363636), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Completion Rate", style: TextStyle(color: Colors.white, fontSize: 16)),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 55, height: 55,
                child: CircularProgressIndicator(
                  value: rate / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.white10,
                  color: const Color(0xFF8687E7),
                ),
              ),
              Text("${rate.toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(BuildContext context) {
    final categoryData = context.read<TaskCubit>().getTaskCountByCategory();
    if (categoryData.isEmpty) {
      return Container(
        height: 150, width: double.infinity,
        decoration: BoxDecoration(color: const Color(0xFF363636), borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text("No Data Available", style: TextStyle(color: Colors.grey))),
      );
    }
    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF363636), borderRadius: BorderRadius.circular(12)),
      child: PieChart(
        PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 35,
          sections: categoryData.entries.map((e) {
            final idx = categoryData.keys.toList().indexOf(e.key);
            return PieChartSectionData(
              value: e.value.toDouble(),
              title: e.key,
              color: Colors.primaries[idx % Colors.primaries.length],
              radius: 55,
              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );
  }
}