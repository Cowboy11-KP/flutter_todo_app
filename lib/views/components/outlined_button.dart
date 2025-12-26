import 'package:flutter/material.dart';

class OutlinedButtonCustom extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final TextStyle? style;
  final Widget? icon;

  const OutlinedButtonCustom({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.style,
    this.icon
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(color: Color(0xFF8875FF), width: 1.5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: style ?? Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
