import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final bool obscureText;
  final bool enabledBorder;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.hint,
    this.obscureText = false,
    this.enabledBorder = true,
    this.controller,
    this.validator,
    this.focusNode
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextFormField(
          focusNode: focusNode,
          validator: validator,
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          cursorColor: const Color(0xFF8875FF),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  BorderSide(
                    color: enabledBorder
                      ? const Color(0xFF979797)
                      : Colors.transparent, 
                  width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  const BorderSide(color: Color(0xFF8875FF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
