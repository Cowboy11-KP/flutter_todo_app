import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final bool isPassword;
  final bool enabledBorder;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.hint,
    this.isPassword = false,
    this.enabledBorder = true,
    this.controller,
    this.validator,
    this.focusNode,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // Khởi tạo trạng thái ẩn nếu là password
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextFormField(
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          validator: widget.validator,
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          style: const TextStyle(color: Colors.white),
          cursorColor: const Color(0xFF8875FF),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: widget.enabled ? const Color(0xFF979797) : Colors.white10,
                  ),
                  onPressed: widget.enabled 
                      ? () => setState(() => _obscureText = !_obscureText)
                      : null,
                )
              : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  BorderSide(
                    color: widget.enabledBorder
                      ? const Color(0xFF979797)
                      : Colors.transparent, 
                  width: 1),
            ),  
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  const BorderSide(color: Color(0xFF8875FF), width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.white10, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
