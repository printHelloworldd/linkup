import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/config/theme/app_theme.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(AppThemeData.themes[AppTheme.darkGreenTheme]!);

  ThemeData? theme;

  void setTheme(AppTheme theme) {
    emit(AppThemeData.themes[theme]!);
  }
}
