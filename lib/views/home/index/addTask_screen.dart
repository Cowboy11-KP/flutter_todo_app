import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/viewmodels/task_cubit.dart';
import 'package:frontend/views/components/Custom_textField.dart';
import 'package:frontend/views/components/custom_calendar.dart';
import 'package:frontend/views/components/custom_category.dart';
import 'package:frontend/views/components/custom_task_priority_screen.dart';
import 'package:frontend/views/components/custom_timepicker.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet();

  @override
  State<AddTaskSheet> createState() => AddTaskSheetState();
}

class AddTaskSheetState extends State<AddTaskSheet> {
  
  final _formKey = GlobalKey<FormState>();
  int _stepIndex = 0;

  final _taskController = TextEditingController();
  final _desController = TextEditingController();
  DateTime? selectedDateTime; 
  String? selectedCategory;
  int? taskPriority;

  Future<void> showChooseDayAndTime() async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: CustomCalendar.gridView(),
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
      taskPriority = result; 
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

      context.read<TaskCubit>().addTask( 
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
                  "assets/icons/send.svg",
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