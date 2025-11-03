import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/views/components/primary_button.dart';
import 'package:intl/intl.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({Key? key}) : super(key: key);

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate = DateTime.now();

  List<DateTime> _generateDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstDayToDisplay =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    final lastDayToDisplay =
        lastDayOfMonth.add(Duration(days: 6 - (lastDayOfMonth.weekday % 7)));

    return List.generate(
      lastDayToDisplay.difference(firstDayToDisplay).inDays + 1,
      (i) => DateTime(firstDayToDisplay.year, firstDayToDisplay.month,
          firstDayToDisplay.day + i),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset);
    });
  }

  void showChooseTime (){
    showDialog(
      context: context, 
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: const CustomTimePicker(),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final days = _generateDaysInMonth(_currentMonth);
    final monthName = DateFormat('MMMM').format(_currentMonth);
    final today = DateTime.now();

    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
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
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white70),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // WEEK DAYS HEADER 
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
                      color: isWeekend ? Colors.redAccent : Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
              ),
            ),

          // DAYS GRID
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 6,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == _currentMonth.month;
              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == day.year &&
                  _selectedDate!.month == day.month &&
                  _selectedDate!.day == day.day;
                final isPastDay = day.isBefore(DateTime(today.year, today.month, today.day));
              return GestureDetector(
                onTap: (isCurrentMonth && !isPastDay)
                    ? () => setState(() => _selectedDate = day)
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.deepPurpleAccent
                        : (isCurrentMonth && !isPastDay)
                            ? Colors.white12
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

          // BUTTONS 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.deepPurpleAccent)),
                ),
                PrimaryButton(
                  onPressed: showChooseTime,
                  text: 'Choose Time',
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CustomTimePicker extends StatefulWidget {
  const CustomTimePicker({super.key});

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  int selectedHour = 8;
  int selectedMinute = 20;
  bool isAM = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose Time',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const Divider(color: Colors.white24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hours
                Container(
                  height: 64,
                  width: 64,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Color(0xff272727)
                  ),
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: selectedHour - 1),
                    itemExtent: 36,
                    onSelectedItemChanged: (i) => setState(() => selectedHour = i + 1),
                    children: List.generate(
                      12,
                      (i) => Center(
                        child: Text('${i + 1}',
                            style: const TextStyle(color: Colors.white, fontSize: 22)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                const Text(':',style: TextStyle(color: Colors.white, fontSize: 24)),
                const SizedBox(width: 7),
                // Minutes
                Container(
                  height: 64,
                  width: 64,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Color(0xff272727)
                  ),
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: selectedMinute),
                    itemExtent: 36,
                    onSelectedItemChanged: (i) => setState(() => selectedMinute = i),
                    children: List.generate(
                      60,
                      (i) => Center(
                        child: Text(i.toString().padLeft(2, '0'),
                            style: const TextStyle(color: Colors.white, fontSize: 22)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // AM/PM
                Container(
                  height: 64,
                  width: 64,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Color(0xff272727)
                  ),
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: isAM ? 0 : 1),
                    itemExtent: 36,
                    onSelectedItemChanged: (i) => setState(() => isAM = i == 0),
                    children: const [
                      Center(child: Text('AM', style: TextStyle(color: Colors.white, fontSize: 22))),
                      Center(child: Text('PM', style: TextStyle(color: Colors.white, fontSize: 22))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 21),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
                  onPressed: () => Navigator.pop(context),
                ),
                PrimaryButton(
                  onPressed: () {
                  },
                  text: 'Save',
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
