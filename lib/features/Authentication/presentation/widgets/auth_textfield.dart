import 'package:flutter/material.dart';
import 'package:linkup/core/presentation/widgets/custom_text_field.dart';

class AuthTextfield extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final Function(String)? onChanged;

  const AuthTextfield({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      textEditingController: controller,
      obscureText: obscureText,
      hintText: hintText,
      maxLines: 1,
      onChanged: (value) => onChanged == null ? {} : onChanged!(value),
    );
  }
}
