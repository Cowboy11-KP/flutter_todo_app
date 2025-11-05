import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            )
          ],
        )
      ),
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _taskController = TextEditingController();
  final _desController = TextEditingController();
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

  Future<void> showChooseTime (){
    return showDialog(
      context: context, 
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: const TimePickerScreen(),
        );
      },
    );
  }

  Future<void> showChooseCategory(){
   return showDialog(
      context: context, 
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: const CategoryScreen(),
        );
      },
    );
  }

  Future<void> showTaskPriority(){
   return showDialog(
      context: context, 
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: const TaskPriority(),
        );
      },
    );
  }


  void handleAddButtonPressed() async {
    if (_stepIndex == 0) {
      await showChooseDay();
      setState(() {
        _stepIndex = 1;
        debugPrint("➡️ Step changed to $_stepIndex");
      });
    } if (_stepIndex == 1) {
      await showChooseTime();
      setState(() {
        _stepIndex = 2;
        debugPrint("➡️ Step changed to $_stepIndex");
      });
    } else if (_stepIndex == 2) {
      await showChooseCategory();
      setState(() {
        _stepIndex = 3;
      });
    } else if (_stepIndex == 3) {
      await showTaskPriority();
      setState(() {
        _stepIndex = 4;
      });
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
          CustomTextField(
            enabledBorder: false,
            hint: 'Do math homework',
            controller: _taskController,
          ),
          const SizedBox(height: 13),
          CustomTextField(
            enabledBorder: false,
            hint: 'Description',
            controller: _desController,
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

