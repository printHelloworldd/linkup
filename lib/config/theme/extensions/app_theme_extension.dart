import 'package:flutter/material.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_snack_bar_theme.dart';
import 'package:linkup/config/theme/extensions/custom_button_theme.dart';
import 'package:linkup/config/theme/extensions/welcome_text_theme.dart';

extension AppThemeExtension on ThemeData {
  /// Usage example: Theme.of(context).appColors;
  AppColors get appColors =>
      extension<AppColors>() ??
      (throw FlutterError('Missing AppColors in ThemeData'));

  AppSnackBarTheme get appSnackBarTheme => extension<AppSnackBarTheme>()!;

  WelcomeTextTheme get welcomeTextTheme => extension<WelcomeTextTheme>()!;

  CustomButtonTheme get customButtonTheme => extension<CustomButtonTheme>()!;
}
