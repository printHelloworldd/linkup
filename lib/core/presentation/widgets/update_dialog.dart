import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/features/Profile/presentation/bloc/app_version/app_version_bloc.dart';

class UpdateDialog {
  static void showUpdateDialog(BuildContext context, String newVersion) {
    final AppColors appColors = context.theme.appColors;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update available!'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'New version of the application ($newVersion) is available. It is recommended to update to get the latest changes.'),
            // const SizedBox(height: 12),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) {
            //       return ReleaseNotesScreen();
            //     }));
            //   },
            //   child: const Text(
            //     "See what's new ->",
            //     style: TextStyle(
            //       color: AppTheme.primaryColor,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Later',
              // style: TextStyle(
              //   color: AppTheme.secondaryColor,
              // ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.popUntil(context, (route) => route.isFirst);

              // currentVersion = newVersion;

              context.read<AppVersionBloc>().add(Update());
            },
            child: Text(
              'Update now',
              style: TextStyle(
                color: appColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
