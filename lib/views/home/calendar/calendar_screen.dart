import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/data/constants/default_categories.dart';
import 'package:frontend/data/models/task_model.dart';
import 'package:frontend/theme/app_color.dart';
import 'package:frontend/viewmodels/task_cubit.dart';
import 'package:frontend/viewmodels/task_state.dart';
import 'package:frontend/views/components/custom_app_bar.dart';
import 'package:frontend/views/components/custom_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _showToday = true;
  bool _showCompleted = false;
  DateTime _selectedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Calendar',
        showBack: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomCalendar.listView(
            hideButton: true, 
            onDateSelected: (date){
              setState(() => _selectedDay = date);
            }
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TaskLoaded || state is TaskActionSuccess) {
                  final Tasks = (state is TaskLoaded)
                      ? state.Tasks
                      : (state as TaskActionSuccess).Tasks;

                  final todayTasks = Tasks.where((Task) {
                    final d = Task.date;
                    return !Task.isDone &&
                        d.year == _selectedDay.year &&
                        d.month == _selectedDay.month &&
                        d.day == _selectedDay.day;
                  }).toList();

                  final completedTasks = Tasks.where((Task) => Task.isDone).toList();
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildButton(
                                isSelected: _showToday,
                                text: 'Today',
                                onPressed: () => setState(() {
                                  _showToday = true;
                                  _showCompleted = false;
                                }),
                              )
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 1,
                              child: _buildButton(
                                isSelected: _showCompleted,
                                text: 'Completed',
                                onPressed: () => setState(() {
                                  _showToday = false;
                                  _showCompleted = true;
                                }),
                              )
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        child: Column(
                          children: _showToday 
                            ? todayTasks.map((Task) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 24),
                                child: _buildTaskItem(context, Task),
                            )).toList()
                            : completedTasks.map((Task) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 24),
                                child: _buildTaskItem(context, Task)
                            )).toList()
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            )
          )
        ],
      ),
    );
  }

  Widget _buildButton ({required String text, required VoidCallback onPressed, required bool isSelected}){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary
          )
        ),
        textStyle: Theme.of(context).textTheme.labelLarge,
        elevation: 0,
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent
      ),
      onPressed: onPressed,
      child: Text(
        text,
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskModel Task) {
    final category = defaultCategories.firstWhere((cat) => cat.label == Task.category);
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4)
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Icon(Icons.circle_outlined),
          title: Text(
            Task.title,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today At ${Task.date.hour}:${Task.date.minute}',
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
                  Task.priority != null
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
                              Task.priority.toString(),
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


