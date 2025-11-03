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

  @override
  Widget build(BuildContext context) {
    final days = _generateDaysInMonth(_currentMonth);
    final monthName = DateFormat('MMMM').format(_currentMonth);
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Container(
          width: 350,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- HEADER ---
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

              // --- Divider ---
              Container(
                height: 1,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),

              // --- WEEK DAYS HEADER ---
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

              // --- DAYS GRID ---
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
                    child: SizedBox(
                      height: 24,
                      width: 24,
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
                    ),
                  );
                },
              ),

              // --- ACTION BUTTONS ---
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
                      onPressed: (){},
                      text: 'Choose Time',
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
