// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final Function(String value)? onChanged;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String hintText;
  final bool? obscureText;

  const CustomTextField({
    super.key,
    required this.textEditingController,
    required this.hintText,
    this.onChanged,
    this.maxLines,
    this.keyboardType,
    this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return TextField(
      controller: textEditingController,
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(value);
        }
      },
      maxLines: maxLines,
      obscureText: obscureText ?? false,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      style: TextStyle(color: appColors.secondary),
    );
  }
}
