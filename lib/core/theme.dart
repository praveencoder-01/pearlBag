import 'package:flutter/material.dart';
import 'package:food_website/theme/app_colors.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,

  scaffoldBackgroundColor: AppColors.scaffold,

  colorScheme: ColorScheme(
    brightness: Brightness.light,

    primary: AppColors.primary,
    onPrimary: Colors.white,

    secondary: AppColors.secondary,
    onSecondary: AppColors.textPrimary,

    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,

    error: AppColors.error,
    onError: Colors.white,
  ),

  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Color.fromARGB(255, 250, 250, 250),
    indicatorColor: Colors.transparent,
    elevation: 0,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    elevation: 0,
  ),

  fontFamily: 'Inter',
);
