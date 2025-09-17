import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.labelText,
    this.onChanged,
    this.keyboardType


  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10),
        hintText: hintText,

        hintStyle: TextStyle(color: Colors.grey[700]),
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon,color: Colors.indigo,) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.indigo,width: 1)
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25)
        )
      ),
      onChanged: onChanged,
    );
  }
}
