import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Icon? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        counterText: maxLength != null ? '' : null, // Hide counter when maxLength is set
      ),
      validator: validator,
    );
  }
}
