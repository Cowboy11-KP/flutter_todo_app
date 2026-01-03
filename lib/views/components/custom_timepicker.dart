import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/views/components/primary_button.dart';

class TimePickerScreen extends StatefulWidget {
  final DateTime initialDate;
  const TimePickerScreen({super.key, required this.initialDate});

  @override
  State<TimePickerScreen> createState() => _TimePickerScreenState();
}

class _TimePickerScreenState extends State<TimePickerScreen> {

  bool is24HourFormat(BuildContext context) {
    final now = DateTime.now();
    final format = DateFormat.jm().format(now); // '5:08 PM' hay '17:08'
    return !format.contains(RegExp(r'[APap][Mm]'));
  }

  late int selectedHour;
  late int selectedMinute;
  late bool isAM;
  late bool use24Hour;

  @override
  void initState() {
    super.initState();
    use24Hour = is24HourFormat(context);
    DateTime now = DateTime.now().add(const Duration(hours: 1));

    if (use24Hour) {
      selectedHour = now.hour; // 0-23
    } else {
      selectedHour = now.hour % 12;
      if (selectedHour == 0) selectedHour = 12;
      isAM = now.hour < 12;
    }
    selectedMinute = now.minute;
  }

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
          const Text('Choose Time',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 21),
            child: Row(
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
          ),
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
                    int hour24;
                
                    if (use24Hour) {
                      hour24 = selectedHour;
                    } else {
                      hour24 = selectedHour % 12;
                      if (!isAM) hour24 += 12;
                    }
                    final fullDateTime = DateTime(
                      widget.initialDate.year,
                      widget.initialDate.month,
                      widget.initialDate.day,
                      hour24,
                      selectedMinute,
                    );
                    Navigator.pop(context, fullDateTime);
                  },
                  text: 'Choose Time',
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}