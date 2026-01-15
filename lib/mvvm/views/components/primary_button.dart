import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final double? width;

  const PrimaryButton({
    super.key,
    this.textStyle,
    required this.text,
    required this.onPressed,
    this.width
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: textStyle ?? Theme.of(context).textTheme.labelLarge,
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
        ),
      ),
    );
  }
}
