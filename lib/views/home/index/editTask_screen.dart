import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/data/constants/default_categories.dart';
import 'package:frontend/models/category_model.dart';
import 'package:frontend/models/task_model.dart';
import 'package:frontend/theme/app_color.dart';
import 'package:frontend/viewmodels/task_cubit.dart';
import 'package:frontend/viewmodels/task_state.dart';
import 'package:frontend/views/components/custom_calendar.dart';
import 'package:frontend/views/components/custom_category.dart';
import 'package:frontend/views/components/custom_confirm_dialog.dart';
import 'package:frontend/views/components/custom_editTitle.dart';
import 'package:frontend/views/components/custom_task_priority_screen.dart';
import 'package:frontend/views/components/custom_timepicker.dart';
import 'package:frontend/views/components/primary_button.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  String? title;
  String? description;
  DateTime? selectedDateTime; 
  String? selectedCategory;
  int? taskPriority;
  bool? isDoneStatus;
  
  Future<void> showTitle() async {
  final result = await showDialog<Map<String, String>>(
      context: context, 
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: CustomEdittitle(task: widget.task),
        );
      },
    );

    if (result != null) {
    setState(() {
      title = result['title'];
      description = result['description'];
    });
  }
    debugPrint("⭐ taskPriority = $taskPriority");
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final displayTitle = title ?? widget.task.title;
    final displayDescription = description ?? widget.task.description;
    final displayTime = selectedDateTime ?? widget.task.date;
    final displayPriority = taskPriority ?? widget.task.priority;
    final currentCategoryLabel = selectedCategory ?? widget.task.category;
    final displayIsDone = isDoneStatus ?? widget.task.isDone;

    CategoryModel? displayCategoryModel;
    try {
      if (currentCategoryLabel != null) {
        displayCategoryModel = defaultCategories.firstWhere(
          (cat) => cat.label == currentCategoryLabel,
        );
      }
    } catch (_) {
      displayCategoryModel = null;
    }
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.cancel_presentation_rounded, size: 32),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              titleAlignment: ListTileTitleAlignment.top,
              leading: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Icon(Icons.circle_outlined),
              ),
              title: Text(
                displayTitle,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                displayDescription ?? 'Dont have description',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary)
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => showTitle(),
                ),
              ),
            ),
            const SizedBox(height: 34),
            _buildItem(
              context, 
              pathSvg: 'assets/icons/clock.svg', 
              name: 'Task Time :', 
              onPressed: () => showChooseDayAndTime() ,
              label: 'At ${displayTime.hour.toString().padLeft(2, '0')}:${displayTime.minute.toString().padLeft(2, '0')}'
            ),
            const SizedBox(height: 34),
            _buildItem(
              context, 
              pathSvg: 'assets/icons/category.svg', 
              name: 'Task Category :',
              onPressed: () => showChooseCategory(), 
              label: currentCategoryLabel ?? 'Default',
              customIcon: displayCategoryModel != null 
                ? SvgPicture.asset(
                    displayCategoryModel.svgPath,
                    height: 14,
                    width: 14,
                    colorFilter: ColorFilter.mode(AppColors.darken(displayCategoryModel.color,-0.05), BlendMode.srcIn,),
                  )
                : null, 
            ),
            const SizedBox(height: 34),
            _buildItem(
              context, 
              pathSvg: 'assets/icons/flag.svg', 
              name: 'Task Priority :', 
              onPressed: showTaskPriority,
              label: displayPriority?.toString() ?? 'Default',
            ),

            const SizedBox(height: 34),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.check, size: 24,),
                    const SizedBox(width: 8),
                    Text('Is done:', style: theme.textTheme.bodyMedium)
                  ],
                ),
                
                // Sử dụng PopupMenuButton để làm Dropdown
                PopupMenuButton<bool>(
                  initialValue: displayIsDone,
                  onSelected: (bool value) {
                    setState(() {
                      isDoneStatus = value;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
                    PopupMenuItem<bool>(
                      value: true,
                      child: Row(
                        children: [
                          Text('Yes'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<bool>(
                      value: false,
                      child: Row(
                        children: [
                          Text('No'),
                        ],
                      ),
                    ),
                  ],
                  // Đây là phần hiển thị giao diện của nút Dropdown
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          displayIsDone ? "yes" : "No",
                          style: theme.textTheme.labelMedium,
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                showDialog(
                  context: context, 
                  builder: (BuildContext dialogContext) {
                    return CustomConfirmDialog(
                      title: 'Delete Task',
                      actionText: 'Delete',
                      actionColor: Colors.redAccent,
                      content: Padding(
                        padding: EdgeInsetsGeometry.symmetric(vertical: 22),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Are you sure you want to delete this task?',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Task title : ${displayTitle}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      onActionPressed: () async {
                        // Thực hiện logic xóa
                        await context.read<TaskCubit>().deleteTask(widget.task.id);
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/trash.svg',
                    colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  Text('Delete Task', style: theme.textTheme.bodyMedium!.copyWith(color: Colors.red))
                ],  
              ),
            ),
            const Spacer(),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: BlocConsumer<TaskCubit, TaskState>(
                  listener: (context, state) {
                    if (state is TaskLoaded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Update success!')),
                      );
                    } else if (state is TaskError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return PrimaryButton(
                      width: double.infinity,
                      onPressed: () async {
                        final updated = TaskModel(
                          id: widget.task.id,
                          title: displayTitle,
                          description: displayDescription,
                          date: displayTime,
                          category: currentCategoryLabel,
                          priority: displayPriority,
                          isDone: displayIsDone,
                        );
                        await context.read<TaskCubit>().updateTask(updated);
                      },
                      text: 'Edit Task',
                    );
                  },

                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItem (
    BuildContext context, {
      required String pathSvg, 
      required String name, 
      required String label,
      required void Function()? onPressed,
      Widget? customIcon,
    }){

    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(pathSvg),
            const SizedBox(width: 8),
            Text(name, style: theme.textTheme.bodyMedium)
          ],  
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: theme.colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(12)
            )

          ),
          onPressed: onPressed,
          child: Row(
            children: [
              if (customIcon != null) ...[
                customIcon,
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),                  
        )
      ],
    );
  }
}