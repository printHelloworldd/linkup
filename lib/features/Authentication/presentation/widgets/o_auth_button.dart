import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:linkup/config/theme/extensions/o_auth_button_theme.dart';

class OAuthButton extends StatelessWidget {
  final Function() onTap;
  // final String iconPath;
  final Widget child;

  const OAuthButton({
    super.key,
    required this.onTap,
    // required this.iconPath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final OAuthButtonTheme buttonTheme =
        context.theme.extension<OAuthButtonTheme>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: buttonTheme.padding,
        decoration: buttonTheme.decoration,
        child: child,
      ),
    );
  }
}
