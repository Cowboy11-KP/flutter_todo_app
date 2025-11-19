import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/data/constants/default_categories.dart';
import 'package:frontend/data/models/todo_model.dart';
import 'package:frontend/theme/app_color.dart';
import 'package:frontend/viewmodels/todo_cubit.dart';
import 'package:frontend/viewmodels/todo_state.dart';
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
            child: BlocBuilder<TodoCubit, TodoState>(
              builder: (context, state) {
                if (state is TodoLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TodoLoaded || state is TodoActionSuccess) {
                  final todos = (state is TodoLoaded)
                      ? state.todos
                      : (state as TodoActionSuccess).todos;

                  final todayTodos = todos.where((todo) {
                    final d = todo.date;
                    return !todo.isDone &&
                        d.year == _selectedDay.year &&
                        d.month == _selectedDay.month &&
                        d.day == _selectedDay.day;
                  }).toList();

                  final completedTodos = todos.where((todo) => todo.isDone).toList();
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
                            ? todayTodos.map((todo) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 24),
                                child: _buildTodoItem(context, todo),
                            )).toList()
                            : completedTodos.map((todo) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 24),
                                child: _buildTodoItem(context, todo)
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

  Widget _buildTodoItem(BuildContext context, TodoModel todo) {
    final category = defaultCategories.firstWhere((cat) => cat.label == todo.category);
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


