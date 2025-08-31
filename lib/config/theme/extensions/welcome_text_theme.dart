import 'package:flutter/material.dart';

class WelcomeTextTheme extends ThemeExtension<WelcomeTextTheme> {
  final TextStyle textStyle;

  WelcomeTextTheme({required this.textStyle});

  @override
  WelcomeTextTheme copyWith({
    TextStyle? textStyle,
  }) {
    return WelcomeTextTheme(
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  WelcomeTextTheme lerp(ThemeExtension<WelcomeTextTheme>? other, double t) {
    if (other is! WelcomeTextTheme) return this;
    return WelcomeTextTheme(
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t)!,
    );
  }
}
