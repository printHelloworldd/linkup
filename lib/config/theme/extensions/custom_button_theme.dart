import 'package:flutter/material.dart';

class CustomButtonTheme extends ThemeExtension<CustomButtonTheme> {
  final EdgeInsetsGeometry padding;
  final BoxDecoration decoration;

  CustomButtonTheme({
    required this.padding,
    required this.decoration,
  });

  @override
  CustomButtonTheme copyWith({
    BoxDecoration? decoration,
    EdgeInsetsGeometry? padding,
  }) {
    return CustomButtonTheme(
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
    );
  }

  @override
  CustomButtonTheme lerp(ThemeExtension<CustomButtonTheme>? other, double t) {
    if (other is! CustomButtonTheme) return this;
    return CustomButtonTheme(
      decoration: BoxDecoration.lerp(decoration, other.decoration, t)!,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t)!,
    );
  }
}
