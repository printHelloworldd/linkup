// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';

class UnblockButton extends StatelessWidget {
  final Function() onTap;

  const UnblockButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              context.tr("blocked_users_page.unblock_user"),
              style: TextStyle(
                color: appColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
