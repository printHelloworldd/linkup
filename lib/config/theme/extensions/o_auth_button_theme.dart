import 'package:flutter/material.dart';

class OAuthButtonTheme extends ThemeExtension<OAuthButtonTheme> {
  final BoxDecoration decoration;
  final EdgeInsetsGeometry padding;

  OAuthButtonTheme({
    required this.decoration,
    required this.padding,
  });

  @override
  OAuthButtonTheme copyWith({
    BoxDecoration? decoration,
    EdgeInsetsGeometry? padding,
  }) {
    return OAuthButtonTheme(
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
    );
  }

  @override
  OAuthButtonTheme lerp(ThemeExtension<OAuthButtonTheme>? other, double t) {
    if (other is! OAuthButtonTheme) return this;
    return OAuthButtonTheme(
      decoration: BoxDecoration.lerp(decoration, other.decoration, t)!,
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t)!,
    );
  }
}
