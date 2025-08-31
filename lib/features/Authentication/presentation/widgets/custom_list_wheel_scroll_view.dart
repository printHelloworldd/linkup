// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomListWheelScrollView extends StatelessWidget {
  final FixedExtentScrollController controller;
  final Function(int index) onSelectedItemChanged;
  final int childCount;
  final Widget Function(BuildContext, int) builder;
  final double height;
  final double width;

  const CustomListWheelScrollView({
    super.key,
    required this.controller,
    required this.onSelectedItemChanged,
    required this.childCount,
    required this.builder,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) => onSelectedItemChanged(index),
        overAndUnderCenterOpacity: 0.5,
        itemExtent: 38,
        perspective: 0.005,
        offAxisFraction: -0.5,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: childCount,
          builder: builder,
        ),
      ),
    );
  }
}
