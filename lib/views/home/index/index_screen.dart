import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/data/constants/default_categories.dart';
import 'package:frontend/data/models/todo_model.dart';
import 'package:frontend/theme/app_color.dart';
import 'package:frontend/viewmodels/todo_cubit.dart';
import 'package:frontend/viewmodels/todo_state.dart';
import 'package:frontend/views/home/index/addTask_screen.dart';

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
              child: BlocBuilder<TodoCubit, TodoState>(
                builder: (context, state) {
                  if (state is TodoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TodoLoaded || state is TodoActionSuccess) {
                    final todos = (state is TodoLoaded)
                        ? state.todos
                        : (state as TodoActionSuccess).todos;

                    final now = DateTime.now();

                    final todayTodos = todos.where((todo) {
                      final d = todo.date;
                      return !todo.isDone &&
                          d.year == now.year &&
                          d.month == now.month &&
                          d.day == now.day;
                    }).toList();

                    final completedTodos =
                        todos.where((todo) => todo.isDone).toList();
                    if (todayTodos.isNotEmpty){
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
                                        children: todayTodos
                                                .map((todo) =>
                                                    _buildTodoItem(context, todo))
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
                                        children: completedTodos.isEmpty
                                            ? [
                                                const SizedBox(height: 8),
                                                const Text('No completed tasks')
                                              ]
                                            : completedTodos
                                                .map((todo) =>
                                                    _buildTodoItem(context, todo))
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
                            const SizedBox(height: 200),
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

  Widget _buildTodoItem(BuildContext context, TodoModel todo) {
    final category = defaultCategories.firstWhere((cat) => cat.label == todo.category);
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2E2E2E),
          borderRadius: BorderRadius.circular(4)
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Icon(Icons.circle_outlined),
          title: Text(
            todo.title,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today At ${todo.date.hour}:${todo.date.minute}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary)
              ),
              Row(
                children: [
                  Container(
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
                  ),
                  const SizedBox(width: 12),
                  todo.priority != null
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
                              todo.priority.toString(),
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
    );
  }
}
