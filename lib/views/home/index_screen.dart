import 'package:flutter/material.dart';
import 'package:frontend/views/components/Custom_textField.dart';

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

  @override
  void initState() {
    super.initState();
    // Focus ngay khi mở
    Future.delayed(const Duration(milliseconds: 200), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Save Task', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

