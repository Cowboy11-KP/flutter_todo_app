import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/data/constants/default_categories.dart';
import 'package:frontend/models/category_model.dart';
import 'package:frontend/models/task_model.dart';
import 'package:frontend/theme/app_color.dart';
import 'package:frontend/viewmodels/task_cubit.dart';
import 'package:frontend/viewmodels/task_state.dart';
import 'package:frontend/views/components/pulse_glow_animation.dart';
import 'package:frontend/views/home/index/addTask_screen.dart';
import 'package:frontend/views/home/index/editTask_screen.dart';

class IndexScreen extends StatefulWidget {
  final VoidCallback? onAddPressed;

  const IndexScreen({super.key, this.onAddPressed});

  @override
  State<IndexScreen> createState() => IndexScreenState();
}

class IndexScreenState extends State<IndexScreen>
    with TickerProviderStateMixin {
  bool _showToday = true;
  bool _showCompleted = true;

  void showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddTaskSheet(),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadTodos();
    widget.onAddPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.filter_list),
                Text('Index', style: Theme.of(context).textTheme.headlineMedium),
                ClipOval(
                    child:
                        Container(height: 42, width: 42, color: Colors.white))
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 Danh sách Task theo nhóm
            Expanded(
              child: BlocBuilder<TaskCubit, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TaskLoaded || state is TaskActionSuccess) {
                    final tasks = (state is TaskLoaded)
                        ? state.tasks
                        : (state as TaskActionSuccess).tasks;

                    final now = DateTime.now();

                    final todayTasks = tasks.where((task) {
                      final d = task.date;
                      return !task.isDone &&
                          d.year == now.year &&
                          d.month == now.month &&
                          d.day == now.day;
                    }).toList();

                    final completedTasks = tasks.where((task) {
                      final d = task.date;
                      return task.isDone &&
                          d.year == now.year &&
                          d.month == now.month &&
                          d.day == now.day;
                    }).toList();

                    if (todayTasks.isNotEmpty ){
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ---------------- TODAY SECTION ----------------
                            _buildSectionHeader(
                              title: 'Today',
                              expanded: _showToday,
                              onTap: () =>
                                  setState(() => _showToday = !_showToday),
                            ),

                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topCenter,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: _showToday
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: todayTasks
                                                .map((task) =>
                                                    _buildTaskItem(context, task))
                                                .toList(),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ---------------- COMPLETED SECTION ----------------
                            _buildSectionHeader(
                              title: 'Completed',
                              expanded: _showCompleted,
                              onTap: () =>
                                  setState(() => _showCompleted = !_showCompleted),
                            ),

                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topCenter,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: _showCompleted
                                    ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                        children: completedTasks.isEmpty
                                            ? [
                                                const SizedBox(height: 8),
                                                const Text('No completed tasks')
                                              ]
                                            : completedTasks
                                                .map((task) =>
                                                    _buildTaskItem(context, task))
                                                .toList(),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/empty.svg'),
                            Text(
                              'What do you want to do today?',
                              style: Theme.of(context).textTheme.headlineMedium
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap + to add your tasks',
                              style: Theme.of(context).textTheme.bodyLarge
                            )
                          ],
                        ),
                      );
                    }
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
              style: Theme.of(context).textTheme.labelMedium
            ),
            const SizedBox(width: 10),
            Icon(expanded ? Icons.expand_less : Icons.expand_more)
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel task) {

    final now = DateTime.now();

    final bool isOverdue = !task.isDone && task.date.isBefore(now);
    final bool isDueNow = !task.isDone && 
        task.date.isAfter(now.subtract(const Duration(minutes: 1))) && 
        task.date.isBefore(now.add(const Duration(minutes: 15)));

    // Get List category
    CategoryModel? category;
    try {
      category = defaultCategories.firstWhere(
        (cat) => cat.label == task.category,
      );
    } catch (_) {
      category = null;
    }

    final Color timeColor = isOverdue
      ? Colors.redAccent
      : Theme.of(context).colorScheme.secondary;

    return PulseGlowWrapper(
      isEnabled: isDueNow,
      glowColor: Theme.of(context).colorScheme.primary,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => EditTaskScreen(task: task))
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2E2E2E),
            borderRadius: BorderRadius.circular(4),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Icon(Icons.circle_outlined),
            title: Text(
              task.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  decoration: isOverdue ? TextDecoration.lineThrough : null,
                ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today At ${task.date.hour.toString().padLeft(2, '0')}:${task.date.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: timeColor)
                ),
                Row(
                  children: [
                    category != null
                      ? Container(
                        margin: EdgeInsets.only(top: 6),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              category.svgPath,
                              height: 14,
                              width: 14,
                              colorFilter: ColorFilter.mode(AppColors.darken(category.color, 0.5), BlendMode.srcIn,),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              category.label,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.darken(category.color, 0.5)
                              )
                            )
                          ],
                        )
                      )
                      : Container(),
                    const SizedBox(width: 12),
                    task.priority != null
                      ? Container(
                        margin: EdgeInsets.only(top: 6),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1)
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset('assets/icons/flag.svg', width: 14, height: 14,),
                              const SizedBox(width: 5),
                              Text(
                                task.priority.toString(),
                                style: Theme.of(context).textTheme.labelMedium,
                              )
                            ],
                          )
                        )
                      : Container()
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
