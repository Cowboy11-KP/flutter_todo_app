import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/viewmodels/todo_cubit.dart';
import 'package:frontend/viewmodels/todo_state.dart';
import 'package:frontend/views/components/custom_app_bar.dart';
import 'package:frontend/views/components/custom_calendar.dart';
import 'package:frontend/views/components/outlined_button.dart';
import 'package:frontend/views/components/primary_button.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _showToday = true;
  bool _showCompleted = true;
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
          CustomCalendar.listView(hideButton: true),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<TodoCubit, TodoState>(
              builder: (context, state) {
                if (state is TodoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TodoLoaded ||
                      state is TodoActionSuccess) {
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
                                child: PrimaryButton(
                                  text: 'Today',
                                  textStyle: theme.textTheme.bodyLarge, 
                                  onPressed: (){}
                                ),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                flex: 1,
                                child: OutlinedButtonCustom(
                                  onPressed: (){},
                                  text: 'Completed',
                                ),
                              )
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              
                            ],
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

  Widget _buildButton ({required String text, required VoidCallback onPressed}){
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge,
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
        ),
      );
  }
}


