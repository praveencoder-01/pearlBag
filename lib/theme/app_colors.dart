import 'package:flutter/material.dart';

class AppColors {
  // Brand / Base
  static const scaffold = Color(0xFFF6F7F9); // main background
  static const card = Colors.white;
  
  // static const cardShadow = Color(0x14000000);

  static const primary = Color.fromARGB(
    255,
    30,
    31,
    31,
  ); // brand accent (buttons, highlights)
  static const secondary = Color(0xFFEAECC6);

  // Text
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0x8A000000); // black54
  static const textDisabled = Color(0x61000000);

  // Surfaces
  static const surface = scaffold;
  static const surfaceVariant = Color(0xFFEDEDEB);

  // Borders / Dividers
  static const divider = Color(0x1F000000);

  // Feedback
  static const error = Color(0xFFB00020);
  static const success = Color(0xFF2E7D32);

  // Overlay
  static const overlayDark = Color(0x8A000000);
}
