import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                const Text(':',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
                // Minutes
                SizedBox(
                  height: 64,
                  width: 64,
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
                // AM/PM
                SizedBox(
                  height: 64,
                  width: 64,
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    print('Selected: $selectedHour:$selectedMinute ${isAM ? "AM" : "PM"}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F7EFD),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
