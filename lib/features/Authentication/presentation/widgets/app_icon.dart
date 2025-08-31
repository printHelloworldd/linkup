import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';

class AppIcon extends StatelessWidget {
  final String iconPath;
  final double size;

  const AppIcon({
    super.key,
    required this.iconPath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return Image.asset(
      iconPath,
      width: size,
      height: size,
      color: appColors.secondary,
    );
  }
}
