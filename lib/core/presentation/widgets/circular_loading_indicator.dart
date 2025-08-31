// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CircularLoadingIndicator extends StatelessWidget {
  final double width;
  final double height;

  const CircularLoadingIndicator({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      // child: CircularProgressIndicator(
      //   color: AppTheme.primaryColor,
      // ),
      child: Lottie.asset(
        "assets/animations/loading_animation.json",
        repeat: true,
        width: width,
        height: height,
      ),
    );
  }
}
