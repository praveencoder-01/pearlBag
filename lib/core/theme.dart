import 'package:flutter/material.dart';
import 'package:food_website/theme/app_colors.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,

  // ⭐ MAIN APP BACKGROUND
  scaffoldBackgroundColor: AppColors.scaffold,

  // ⭐ Important (fixes white cards & pages)
  canvasColor: AppColors.scaffold,

  // ⭐ fixes bottom sheets, dialogs, menus
  dialogBackgroundColor: AppColors.surface,

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
    elevation: 0,
    foregroundColor: AppColors.textPrimary,
  ),

  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: Colors.transparent,
    elevation: 0,
  ),

  fontFamily: 'Inter',
);
