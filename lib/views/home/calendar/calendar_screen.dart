import 'package:flutter/material.dart';
import 'package:frontend/views/components/custom_app_bar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Calendar',
        showBack: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomCalendar(
            hidenButton: true,
            isListView: true,
          )
        ],
      ),
    );
  }
}

class CustomCalendar extends StatefulWidget {
  final bool hidenButton;
  final bool isListView;
  
  const CustomCalendar({
    super.key, 
    this.hidenButton = false,
    this.isListView = false

  });

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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER 
          Row(
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

          // DAYS GRID
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isCurrentMonth = day.month == _currentMonth.month;
                final isSelected = _selectedDate != null &&
                    _selectedDate!.year == day.year &&
                    _selectedDate!.month == day.month &&
                    _selectedDate!.day == day.day;
                final isPastDay = day.isBefore(DateTime(today.year, today.month, today.day));

                final weekday = DateFormat('EEE').format(day).toUpperCase();

                return GestureDetector(
                  onTap: (isCurrentMonth && !isPastDay)
                      ? () => setState(() => _selectedDate = day)
                      : null,
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepPurpleAccent
                          : (isCurrentMonth && !isPastDay)
                              ? const Color(0xFF3A3A3A)
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
                                ? Colors.redAccent // Chủ nhật
                                : (index % 7 == 6)
                                    ? Colors.redAccent // Thứ 7
                                    : Colors.white70,
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
                        // if (!isSelected && (index % 3 == 0))
                        //   const Padding(
                        //     padding: EdgeInsets.only(top: 4),
                        //     child: CircleAvatar(
                        //       radius: 2,
                        //       backgroundColor: Colors.deepPurpleAccent,
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

