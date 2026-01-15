import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/mvvm/models/task/task_model.dart';
import 'package:frontend/mvvm/viewmodels/task/task_cubit.dart';
import 'package:frontend/mvvm/viewmodels/task/task_state.dart';
import 'package:frontend/mvvm/views/components/primary_button.dart';
import 'package:intl/intl.dart';

class CustomCalendar extends StatefulWidget {
  final bool hideButton;
  final bool isListView;
  final void Function(DateTime)? onDateSelected;

  const CustomCalendar._({
    super.key, 
    this.hideButton = false,
    this.isListView = false,
    this.onDateSelected

  });

   static CustomCalendar listView({
    Key? key,
    bool hideButton = false,
    void Function(DateTime)? onDateSelected,
  }) {
    return CustomCalendar._ (
      key: key,
      isListView: true,
      hideButton: hideButton,
      onDateSelected: onDateSelected,
    );
  }

  static CustomCalendar gridView({
    Key? key,
    bool hideButton = false,
    void Function(DateTime)? onDateSelected,
  }) {
    return CustomCalendar._(
      key: key,
      isListView: false,
      hideButton: hideButton,
      onDateSelected: onDateSelected,
    );
  }

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  List<DateTime> _generateDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstDayToDisplay = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    final lastDayToDisplay = lastDayOfMonth.add(Duration(days: 6 - (lastDayOfMonth.weekday % 7)));
    return List.generate(
      lastDayToDisplay.difference(firstDayToDisplay).inDays + 1,
      (i) => DateTime(firstDayToDisplay.year, firstDayToDisplay.month,
          firstDayToDisplay.day + i),
    );
  }

  List<DateTime> _generateOnlyDaysInMonth(DateTime month) {
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      lastDayOfMonth.day,
      (i) => DateTime(month.year, month.month, i + 1),
    );
  }

  void _scrollForMonthView() {
    if (!widget.isListView || !_scrollController.hasClients) return;

    final now = DateTime.now();
    final isRealCurrentMonth = _currentMonth.year == now.year && _currentMonth.month == now.month;

    int targetDay = isRealCurrentMonth ? now.day : 1;
    final index = targetDay - 1; 
    
    const double itemWidth = 58.0; // 48 + 10
    final double screenWidth = MediaQuery.of(context).size.width;

    // Công thức căn giữa
    final targetOffset = (index * itemWidth) - (screenWidth / 2) + (48.0 / 2);
      
    _scrollController.animateTo(
      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollForMonthView());
  }

   void _onSelectDay(DateTime day) {
    setState(() {
      _selectedDate = day;
    });
    widget.onDateSelected?.call(day);
    _scrollToSelected();
  }
  
  void _scrollToSelected() {
    if (!widget.isListView || !_scrollController.hasClients) return;

    final index = _selectedDate.day - 1;
    // 48.0 là width của Container, 10.0 là margin right -> Tổng cộng 58.0
    const double itemWidth = 48.0 + 10.0; 
    final double screenWidth = MediaQuery.of(context).size.width;

    // Tính toán để tâm của item nằm trùng với tâm của màn hình
    // (index * itemWidth): Vị trí bắt đầu của item
    // (screenWidth / 2): Đưa điểm đó về giữa màn hình
    // (48.0 / 2): Bù lại nửa chiều rộng của chính item đó để nó nằm chính xác ở giữa
    final targetOffset = (index * itemWidth) - (screenWidth / 2) + (48.0 / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350), // Tăng nhẹ thời gian cho mượt
      curve: Curves.easeOutCubic, // Dùng curve này nhìn sẽ tự nhiên hơn
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.isListView
      ? _generateOnlyDaysInMonth(_currentMonth)
      : _generateDaysInMonth(_currentMonth);

    final monthName = DateFormat('MMMM').format(_currentMonth);
    final today = DateTime.now();

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
          _buildHeader(monthName),
          widget.isListView
            ? _buildListView(days, today)
            : _buildGridView(days, today),
          if (!widget.hideButton) const SizedBox(height: 8),
          if (!widget.hideButton) _buildActionButtons(),
          
        ],
      ),
    );
  }
  Widget _buildHeader(String monthName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white70),
          onPressed: () => _changeMonth(-1),
        ),
        Column(
          children: [
            Text(
              monthName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _currentMonth.year.toString(),
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white70),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _buildListView(List<DateTime> days, DateTime today){
    final state = context.watch<TaskCubit>().state;
    List<TaskModel> tasks = [];
    if (state is TaskLoaded) tasks = state.tasks;
    if (state is TaskActionSuccess) tasks = state.tasks;

    return SizedBox(
      height: 65,
      child: ListView.builder( 
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isCurrentMonth = day.month == _currentMonth.month;
          final isSelected = _selectedDate.year == day.year &&
                             _selectedDate.month == day.month &&
                             _selectedDate.day == day.day;
          final isPastDay = day.isBefore(DateTime(today.year, today.month, today.day));

          bool hasTask = tasks.any((t) => DateUtils.isSameDay(t.date, day));

          final weekday = DateFormat('EEE').format(day).toUpperCase();

          return GestureDetector(
            onTap: isCurrentMonth
                ? () => _onSelectDay(day)
                : null,
            child: Container(
              width: 48,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : (isCurrentMonth && !isPastDay) 
                        ? Color(0xFF272727)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: (index % 7 == 0)
                          ? Color(0xFFFF383C) // Chủ nhật
                          : (index % 7 == 1)
                              ? Color(0xFFFF383C) // Thứ 7
                              : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isCurrentMonth && !isPastDay)
                              ? Colors.white
                              : Colors.white30,
                    ),
                  ),

                  if (hasTask)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Quá khứ: xám, Hiện tại/Tương lai: đỏ
                      color: isPastDay ? Colors.grey : Theme.of(context).colorScheme.primary,
                    ),
                  )
                else
                  const SizedBox(height: 6),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<DateTime> days, DateTime today){
    return Column(
      children: [
        Divider(color: Colors.white24),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              const weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
              final isWeekend = (index == 0 || index == 6);

              return Text(
                weekDays[index],
                style: TextStyle(
                  color: isWeekend ? Color(0xFFFF383C) : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ),
        ),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 23,
            mainAxisSpacing: 10,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final isCurrentMonth = day.month == _currentMonth.month;
            final isSelected = _selectedDate.year == day.year &&
                               _selectedDate.month == day.month &&
                               _selectedDate.day == day.day;
              final isPastDay = day.isBefore(DateTime(today.year, today.month, today.day));
            return GestureDetector(
              onTap: (isCurrentMonth && !isPastDay)
                  ? () => _onSelectDay(day)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : (isCurrentMonth && !isPastDay)
                          ? Color(0xFF272727)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: (isCurrentMonth && !isPastDay)
                        ? Colors.white
                        : Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(){
    return Row(
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
              Navigator.pop(context, _selectedDate);
            },
            text: 'Choose Day',
          ),
        )
      ],
    );
  }
}

