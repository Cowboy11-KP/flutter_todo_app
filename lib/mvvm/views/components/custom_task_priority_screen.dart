import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/mvvm/views/components/primary_button.dart';
class TaskPriority extends StatefulWidget {
  const TaskPriority({super.key});

  @override
  State<TaskPriority> createState() => _TaskPriorityState();
}

class _TaskPriorityState extends State<TaskPriority> {
  int? _taskPriority;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF363636),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Task Priority',
           style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10,),
          // Divider
          const Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9
              ),
              itemCount: 10,
              itemBuilder: (context, index ) {
                final isSelected = _taskPriority == index;
                return GestureDetector(
                  onTap:() {
                    setState(() {
                      _taskPriority = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepPurpleAccent
                          : Color(0xff272727),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/flag.svg',height: 24,),
                        const SizedBox(height: 5),
                        Text("${index + 1}",
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // BUTTONS 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith
                    (color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ), 
              const SizedBox(width: 15),
              Expanded(
                flex: 1,
                child: PrimaryButton(
                  onPressed: () {
                    int? result = _taskPriority != null ? _taskPriority! + 1 : null;
                    Navigator.pop(context, result);
                  },
                  text: 'Choose',
                ),
              )
            ],
          )
        ],
      ),
    ) ;
  }
}