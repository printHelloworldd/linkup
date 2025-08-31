import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';

class BlockInfoPanel extends StatelessWidget {
  const BlockInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            context.tr("chat_page.restricted"),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
