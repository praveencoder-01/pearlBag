import 'package:flutter/material.dart';
import 'package:food_website/theme/app_colors.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,

  // ⭐ MAIN APP BACKGROUND
  scaffoldBackgroundColor: AppColors.scaffold,

  // ⭐ Important (fixes white cards & pages)
  canvasColor: AppColors.scaffold,

  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSurface: AppColors.textPrimary,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,

    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
  ),

  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: Colors.transparent,
    elevation: 0,
  ),

  fontFamily: 'Inter',
  dialogTheme: DialogThemeData(backgroundColor: AppColors.surface),
);
