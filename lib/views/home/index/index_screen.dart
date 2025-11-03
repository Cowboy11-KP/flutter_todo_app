import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/views/components/Custom_textField.dart';
import 'package:frontend/views/home/index/custom_calendar.dart';

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

  void showChooseday (){
    showDialog(
      context: context, 
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: const CustomCalendar(),
        );
      },
    );
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
                onPressed: showChooseday, 
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

