import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/data/models/todo_model.dart';
import 'package:frontend/viewmodels/todo_cubit.dart';
import 'package:frontend/viewmodels/todo_state.dart';
import 'package:frontend/views/components/Custom_textField.dart';
import 'package:frontend/views/home/index/calendar_screen.dart';
import 'package:frontend/views/home/index/category_screen.dart';
import 'package:frontend/views/home/index/task_priority_screen.dart';
import 'package:frontend/views/home/index/timepicker_screen.dart';

class IndexScreen extends StatefulWidget {
  final VoidCallback? onAddPressed;

  const IndexScreen({super.key, this.onAddPressed});

  @override
  State<IndexScreen> createState() => IndexScreenState();
}

class IndexScreenState extends State<IndexScreen> {

  void showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddTaskSheet(),
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
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.filter_list),
                Text('Index', style: Theme.of(context).textTheme.headlineMedium),
                ClipOval(
                  child: Container(height: 42, width: 42, color: Colors.white)
                )
              ],
            ),

            Expanded(
              child: BlocConsumer<TodoCubit, TodoState>(
                listener: (context, state) {
                  if (state is TodoActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  } else if (state is TodoError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is TodoLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TodoLoaded || state is TodoActionSuccess) {
                    final todos = (state is TodoLoaded)
                        ? state.todos
                        : (state as TodoActionSuccess).todos;

                    if (todos.isEmpty) {
                      return const Center(child: Text('Chưa có task nào'));
                    }

                    return ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return _buildTodoItem(context, todo);
                      },
                    );
                  } else if (state is TodoError) {
                    return Center(child: Text(state.message));
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        )
      ),
    );
  }
}

Widget _buildTodoItem(BuildContext context, TodoModel todo) {
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
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.grey : Colors.white,
          ),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Today At: 16:45'),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    
                  ),
                )
              ],
            )
          ],
        ),
        trailing: Checkbox(
          value: todo.isDone,
          onChanged: (_) => context.read<TodoCubit>().toggleDone(todo),
        ),
        onLongPress: () => context.read<TodoCubit>().deleteTodo(todo.id),
      ),
    ),
  );
}


class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _taskController = TextEditingController();
  final _desController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDateTime; 
  String? selectedCategory;
  int? taskPriority;

  int _stepIndex = 0;

  Future<void> showChooseDay (){
    return showDialog(
      context: context, 
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: const CustomCalendar(),
        );
      },
    );
  }

  Future<void> showChooseDayAndTime() async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: const CustomCalendar(),
      ),
    );

    if (selectedDate == null) return; // user cancel

    final selectedTime = await showDialog<DateTime>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: TimePickerScreen(initialDate: selectedDate),
      ),
    );

    if (selectedTime != null) {
      setState(() {
        selectedDateTime = selectedTime;
      });
      debugPrint("🕓 selectedDateTime = $selectedDateTime");
    }
  }

  Future<void> showChooseCategory() async {
   final result = await showDialog(
      context: context, 
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: const CategoryScreen(),
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedCategory = result;
      });
      debugPrint("📂 selectedCategory = $selectedCategory");
    }
  }

  Future<void> showTaskPriority() async {
   final result = await showDialog(
      context: context, 
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: const TaskPriority(),
        );
      },
    );

    setState(() {
      taskPriority = result; // có thể null nếu user bỏ qua
    });
    debugPrint("⭐ taskPriority = $taskPriority");
  }


  void handleAddButtonPressed() async {
    if (_stepIndex == 0) {
      if(_formKey.currentState!.validate()){
        await showChooseDayAndTime();
        if(selectedDateTime !=null) {
          setState(() =>_stepIndex = 1);
        }
      }
    } if (_stepIndex == 1) {
      await showChooseCategory();
      setState(() =>_stepIndex = 2);
    } if (_stepIndex == 2) {
      await showTaskPriority();

      context.read<TodoCubit>().addTodo( 
        title: _taskController.text,
        description: _desController.text,
        date: selectedDateTime,
        category: selectedCategory,
        priority: taskPriority
      );

      setState(() =>_stepIndex = 0);
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Add Task', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  enabledBorder: false,
                  hint: 'Do math homework',
                  controller: _taskController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Task name cannot be empty';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 13),
                CustomTextField(
                  enabledBorder: false,
                  hint: 'Description',
                  controller: _desController,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          Row(
            children: [
              IconButton(
                onPressed: handleAddButtonPressed,
                icon: SvgPicture.asset(
                  "asset/icons/send.svg",
                  colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
                )
              )
            ],
          )
        ],
      ),
    );
  }
}

