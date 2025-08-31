// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_snack_bar_theme.dart';
import 'package:linkup/config/theme/extensions/custom_button_theme.dart';
import 'package:linkup/config/theme/extensions/o_auth_button_theme.dart';
import 'package:linkup/config/theme/extensions/snack_bar_style.dart';
import 'package:linkup/config/theme/extensions/welcome_text_theme.dart';

enum AppTheme { darkGreenTheme, darkRedTheme }

class AppThemeData {
  // static const Color darkGreenPrimary = Color(0xFFc0f7a6);
  // static const Color darkGreenSecondary = Color(0xFFf6f6f6);
  // static const Color darkGreenBackground = Color(0xFF1b1b1b);

  static final darkGreenColors = AppColors(
    primary: const Color(0xFFc0f7a6),
    secondary: const Color(0xFFf6f6f6),
    background: const Color(0xFF1b1b1b),
    surface: Colors.grey[850]!,
    surfaceHighlight: Colors.grey[500]!,
    hint: Colors.grey[700]!,
    text: Colors.black,
  );

  static final darkRedColors = AppColors(
    primary: const Color(0xFF74070E),
    secondary: const Color(0xFFF4E3B2),
    background: const Color(0xFF310E10),
    surface: const Color(0xFF947268),
    surfaceHighlight: const Color(0xFFF4E3B2),
    hint: const Color(0xFF45462A),
    text: Colors.black,
  );

  static final Map<AppTheme, ThemeData> themes = {
    AppTheme.darkGreenTheme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkGreenColors.background,
      colorScheme: ColorScheme.dark(
        primary: darkGreenColors.primary, // активные элементы
        secondary: darkGreenColors.secondary, // вспомогательные
        onSecondary: Colors.white,
        surface: darkGreenColors.background, // карточки / appBar
      ),
      primaryColor: darkGreenColors.primary,
      // primaryColor: const Color(0xFF1b1b1b),
      // primaryColorLight: const Color(0xFFf6f6f6),
      // primaryColorDark: Colors.black,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: darkGreenColors.primary, // Дефолтный цвет курсора
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              // color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkGreenColors.background,
        titleTextStyle: TextStyle(
          color: darkGreenColors.secondary,
        ),
        contentTextStyle: TextStyle(
          color: darkGreenColors.secondary,
        ),
      ),
      textTheme: TextTheme(
        // displayLarge: TextStyle(
        //   fontSize: 28,
        //   fontWeight: FontWeight.bold,
        //   color: darkGreenSecondary,
        // ),
        bodyMedium: TextStyle(
          color: darkGreenColors.secondary,
          fontSize: 16,
        ),
      ),
      hintColor: Colors.grey[700],
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: darkGreenColors.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: darkGreenColors.secondary,
          fontSize: 24,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: darkGreenColors.background,
        filled: true,
        hintStyle: TextStyle(
          color: Colors.grey[600],
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: darkGreenColors.surfaceHighlight,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[800]!,
            width: 2.0,
          ),
        ),
      ),
    ).copyWith(
      extensions: [
        AppColors(
          primary: darkGreenColors.primary,
          secondary: darkGreenColors.secondary,
          background: darkGreenColors.background,
          surface: darkGreenColors.surface,
          surfaceHighlight: darkGreenColors.surfaceHighlight,
          hint: darkGreenColors.hint,
          text: darkGreenColors.text,
        ),
        OAuthButtonTheme(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFf6f6f6),
          ),
          padding: const EdgeInsets.all(20),
        ),
        AppSnackBarTheme(
          error: SnackBarStyle(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.yellow[600],
            ),
            textStyle: TextStyle(
              fontSize: 16,
              color: darkGreenColors.background,
            ),
          ),
          warning: SnackBarStyle(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.yellow[600],
            ),
            textStyle: TextStyle(
              fontSize: 16,
              color: darkGreenColors.background,
            ),
          ),
          success: SnackBarStyle(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: darkGreenColors.primary,
            ),
            textStyle: TextStyle(
              fontSize: 16,
              color: darkGreenColors.background,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        WelcomeTextTheme(
          textStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: darkGreenColors.secondary,
          ),
        ),
        CustomButtonTheme(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: darkGreenColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    ),
    AppTheme.darkRedTheme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkRedColors.background,
      colorScheme: ColorScheme.dark(
        primary: darkRedColors.primary, // активные элементы
        secondary: darkRedColors.secondary, // вспомогательные
        onSecondary: Colors.white,
        surface: darkRedColors.background, // карточки / appBar
      ),
      primaryColor: darkRedColors.primary,
      // primaryColor: const Color(0xFF1b1b1b),
      // primaryColorLight: const Color(0xFFf6f6f6),
      // primaryColorDark: Colors.black,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: darkRedColors.primary, // Дефолтный цвет курсора
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              // color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkRedColors.background,
        titleTextStyle: TextStyle(
          color: darkRedColors.secondary,
        ),
        contentTextStyle: TextStyle(
          color: darkRedColors.secondary,
        ),
      ),
      textTheme: TextTheme(
        // displayLarge: TextStyle(
        //   fontSize: 28,
        //   fontWeight: FontWeight.bold,
        //   color: darkGreenSecondary,
        // ),
        bodyMedium: TextStyle(
          color: darkRedColors.secondary,
          fontSize: 16,
        ),
      ),
      hintColor: const Color(0xFF45462A),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: darkRedColors.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: darkRedColors.secondary,
          fontSize: 24,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: darkRedColors.background,
        filled: true,
        hintStyle: TextStyle(
          color: darkRedColors.hint,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: darkRedColors.secondary,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: darkRedColors.surface,
            width: 2.0,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: darkRedColors.secondary,
      ),
    ).copyWith(
      extensions: [
        AppColors(
          primary: darkRedColors.primary,
          secondary: darkRedColors.secondary,
          background: darkRedColors.background,
          surface: darkRedColors.surface,
          surfaceHighlight: darkRedColors.surfaceHighlight,
          hint: darkRedColors.hint,
          text: darkRedColors.text,
        ),
        OAuthButtonTheme(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFf6f6f6),
          ),
          padding: const EdgeInsets.all(20),
        ),
        AppSnackBarTheme(
          error: SnackBarStyle(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.yellow[600],
            ),
            textStyle: TextStyle(
              fontSize: 16,
              color: darkRedColors.background,
            ),
          ),
          warning: SnackBarStyle(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.yellow[600],
            ),
            textStyle: TextStyle(
              fontSize: 16,
              color: darkRedColors.background,
            ),
          ),
          success: SnackBarStyle(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: darkRedColors.primary,
            ),
            textStyle: TextStyle(
              fontSize: 16,
              color: darkRedColors.background,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        WelcomeTextTheme(
          textStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: darkRedColors.secondary,
          ),
        ),
        CustomButtonTheme(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: darkRedColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    ),
  };

  // static const Color primaryColor = Color(0xFFc0f7a6);
  // static const Color secondaryColor = Color(0xFFf6f6f6);
  // static const Color backgroundColor = Color(0xFF1b1b1b);
  // static const Color textColor = Colors.black;

  // static final darkGreenTheme = ThemeData(
  //   useMaterial3: true,
  //   brightness: Brightness.dark,
  //   scaffoldBackgroundColor: const Color(0xFF1b1b1b),
  //   colorScheme: const ColorScheme.dark(
  //     primary: darkGreenPrimary, // активные элементы
  //     secondary: darkGreenSecondary, // вспомогательные
  //     onSecondary: Colors.white,
  //     background: darkGreenBackground, // фон
  //     surface: darkGreenBackground, // карточки / appBar
  //   ),
  //   // primaryColor: const Color(0xFFc0f7a6),
  //   // primaryColor: const Color(0xFF1b1b1b),
  //   // primaryColorLight: const Color(0xFFf6f6f6),
  //   // primaryColorDark: Colors.black,
  //   textSelectionTheme: const TextSelectionThemeData(
  //     cursorColor: darkGreenPrimary, // Дефолтный цвет курсора
  //   ),
  //   dialogBackgroundColor: darkGreenBackground,
  //   textButtonTheme: const TextButtonThemeData(
  //     style: ButtonStyle(
  //       backgroundColor: WidgetStatePropertyAll(darkGreenPrimary),
  //       textStyle: WidgetStatePropertyAll(
  //         TextStyle(
  //           // color: Colors.black,
  //           fontWeight: FontWeight.bold,
  //           fontSize: 18,
  //         ),
  //       ),
  //     ),
  //   ),
  //   dialogTheme: const DialogTheme(
  //     backgroundColor: darkGreenSecondary,
  //     titleTextStyle: TextStyle(
  //       color: darkGreenBackground,
  //     ),
  //     contentTextStyle: TextStyle(
  //       color: darkGreenBackground,
  //     ),
  //   ),
  //   textTheme: const TextTheme(
  //     displayLarge: TextStyle(
  //       fontSize: 28,
  //       fontWeight: FontWeight.bold,
  //       color: darkGreenSecondary,
  //     ),
  //     bodyMedium: TextStyle(
  //       color: darkGreenSecondary,
  //       fontSize: 16,
  //     ),
  //   ),
  //   hintColor: Colors.grey[700],
  //   progressIndicatorTheme: const ProgressIndicatorThemeData(
  //     color: darkGreenPrimary,
  //   ),
  //   appBarTheme: const AppBarTheme(
  //     backgroundColor: Colors.transparent,
  //     elevation: 0,
  //     titleTextStyle: TextStyle(
  //       color: darkGreenSecondary,
  //       fontSize: 24,
  //     ),
  //   ),
  //   inputDecorationTheme: InputDecorationTheme(
  //     fillColor: darkGreenBackground,
  //     filled: true,
  //     hintStyle: TextStyle(
  //       color: Colors.grey[600],
  //     ),
  //     focusedBorder: OutlineInputBorder(
  //       borderSide: BorderSide(
  //         color: Colors.grey[500]!,
  //         width: 2.0,
  //       ),
  //     ),
  //     enabledBorder: OutlineInputBorder(
  //       borderSide: BorderSide(
  //         color: Colors.grey[800]!,
  //         width: 2.0,
  //       ),
  //     ),
  //   ),
  // );
}
