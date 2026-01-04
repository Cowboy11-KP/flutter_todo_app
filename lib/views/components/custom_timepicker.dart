import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/views/components/primary_button.dart';

class TimePickerScreen extends StatefulWidget {
  final DateTime initialDate;
  const TimePickerScreen({super.key, required this.initialDate});

  @override
  State<TimePickerScreen> createState() => _TimePickerScreenState();
}

class _TimePickerScreenState extends State<TimePickerScreen> {
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giờ hiện tại + 1 tiếng
    DateTime now = DateTime.now().add(const Duration(hours: 1));
    selectedHour = now.hour; // Lấy trực tiếp 0-23
    selectedMinute = now.minute;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF363636),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Choose Time (24h)',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 21),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- CỘT GIỜ (00 - 23) ---
                Container(
                  height: 64,
                  width: 80, // Tăng nhẹ width để thoải mái hơn
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xff272727),
                  ),
                  child: CupertinoPicker(
                    // Scroll tới vị trí selectedHour hiện tại
                    scrollController: FixedExtentScrollController(initialItem: selectedHour),
                    itemExtent: 36,
                    onSelectedItemChanged: (i) => setState(() => selectedHour = i),
                    children: List.generate(
                      24, // Sinh ra 24 số từ 0 đến 23
                      (i) => Center(
                        child: Text(i.toString().padLeft(2, '0'), // Thêm số 0 phía trước (01, 02...)
                            style: const TextStyle(color: Colors.white, fontSize: 22)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(':', style: TextStyle(color: Colors.white, fontSize: 24)),
                const SizedBox(width: 10),
                // --- CỘT PHÚT (00 - 59) ---
                Container(
                  height: 64,
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xff272727),
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
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ), 
              const SizedBox(width: 15),
              Expanded(
                child: PrimaryButton(
                  onPressed: () {
                    // Tạo Object DateTime mới dựa trên ngày ban đầu và giờ/phút đã chọn
                    final fullDateTime = DateTime(
                      widget.initialDate.year,
                      widget.initialDate.month,
                      widget.initialDate.day,
                      selectedHour,
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