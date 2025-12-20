import 'package:flutter/material.dart';
import 'package:frontend/models/task_model.dart';
import 'package:frontend/views/components/Custom_textField.dart';
import 'package:frontend/views/components/primary_button.dart';
class CustomEdittitle extends StatefulWidget {
  final TaskModel task;

  const CustomEdittitle({super.key, required this.task});

  @override
  State<CustomEdittitle> createState() => _CustomEdittitleState();
}

class _CustomEdittitleState extends State<CustomEdittitle> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _taskController;
  late TextEditingController _desController;
  late FocusNode _titleFocusNode;
  
  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.task.title);
    _desController = TextEditingController(text: widget.task.description);
    _titleFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Edit Task Title',
           style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10,),
          // Divider
          const Divider(color: Colors.white24),
          const SizedBox(height: 15),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  focusNode: _titleFocusNode,
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
          const SizedBox(height: 40),
          // BUTTONS 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.deepPurpleAccent)),
                ),
              ),
              Expanded(
                child: PrimaryButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context, {
                        'title': _taskController.text.trim(),
                        'description': _desController.text.trim(),
                      });
                    }
                  },
                  text: 'Edit',
                ),
              )
            ],
          )
          
        ],
      ), 
    ) ;
  }
}