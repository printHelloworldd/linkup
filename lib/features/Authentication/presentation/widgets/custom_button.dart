import 'package:flutter/material.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/extensions/custom_button_theme.dart';
import 'package:linkup/config/theme/theme_getter.dart';

class CustomButton extends StatelessWidget {
  final Function() onTap;
  final Widget child;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final CustomButtonTheme buttonTheme = context.theme.customButtonTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: buttonTheme.padding,
          decoration: buttonTheme.decoration,
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
