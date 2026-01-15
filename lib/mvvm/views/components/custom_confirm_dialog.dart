import 'package:flutter/material.dart';

class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final Widget content; // Phần thân có thể tùy biến
  final String actionText;
  final VoidCallback onActionPressed;
  final Color? actionColor;

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actionText,
    required this.onActionPressed,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent, // Để Container bo góc hoạt động
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF363636),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white24),
            
            // Phần nội dung tùy biến nằm ở đây
            content,

            // Nút bấm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor ?? const Color(0xFF8875FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: onActionPressed,
                    child: Text(
                      actionText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}