import 'package:flutter/material.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';

class NeuButton extends StatelessWidget {
  final Widget child;
  final Function() onTap;
  final bool isButtonPressed;

  const NeuButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.isButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return GestureDetector(
      onTap: () {
        Future.delayed(const Duration(milliseconds: 200), () {
          onTap();
        });

        // Future.delayed(const Duration(milliseconds: 200), () {
        //   buttonPressed();
        // });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isButtonPressed ? appColors.secondary : Colors.grey[850]!,
          ),
          boxShadow: isButtonPressed
              ? [
                  // no shadows if button is pressed
                ]
              : [
                  // darker shadow on the bottom right
                  BoxShadow(
                    color: Colors.grey[900]!,
                    blurRadius: 15,
                    offset: const Offset(5, 5),
                  ),

                  // lighter shadow on the top left
                  BoxShadow(
                    color: Colors.grey[800]!,
                    blurRadius: 15,
                    offset: const Offset(-5, -5),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Center(child: child),
            if (isButtonPressed)
              Positioned(
                bottom: 5,
                right: 5,
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 24,
                  color: appColors.secondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
