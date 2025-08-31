import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';

class OrContinueWith extends StatelessWidget {
  const OrContinueWith({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final AppColors appColors = theme.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 0.5,
              color: appColors.secondary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              context.tr("auth_page.or"),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 0.5,
              color: appColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
