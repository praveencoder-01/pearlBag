
import 'package:flutter/material.dart';

class AdminTheme {
  // Background + surfaces
  static const bg = Color(0xFFF4F7FF); // soft neutral (light blue-gray)
  static const sidebarBg = Color(0xFF0B1220); // deep navy
  static const sidebarSurface = Color(0xFF0F1A2E); // slightly lighter
  static const card = Colors.white;
  static const border = Color(0xFFE6EAF2);

  // Text
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);

  // Accents
  static const primary = Color(0xFF4F46E5); // Indigo
  static const primary2 = Color(0xFF2563EB); // Blue
  static const success = Color(0xFF10B981); // Emerald
  static const warning = Color(0xFFF59E0B); // Amber
  static const danger = Color(0xFFEF4444); // Red

  // Radii
  static const r12 = Radius.circular(12);
  static const r14 = Radius.circular(14);
  static const r16 = Radius.circular(16);
  static const r18 = Radius.circular(18);

  static BoxDecoration cardDecoration({bool elevated = true}) {
    return BoxDecoration(
      color: card,
      borderRadius: const BorderRadius.all(r16),
      border: Border.all(color: border),
      boxShadow: elevated
          ? const [
              BoxShadow(
                color: Color(0x120B1220),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ]
          : const [],
    );
  }

  static TextStyle h1 = const TextStyle(
    fontSize: 22,
    height: 1.15,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle h2 = const TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static TextStyle body = const TextStyle(
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle meta = const TextStyle(
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );
}

class Breakpoints {
  static const mobile = 600.0;
  static const tablet = 1024.0;

  static bool isMobile(double w) => w < mobile;
  static bool isTablet(double w) => w >= mobile && w < tablet;
  static bool isDesktop(double w) => w >= tablet;
}

class Space {
  static const double x4 = 4;
  static const double x6 = 6;
  static const double x8 = 8;
  static const double x10 = 10;
  static const double x12 = 12;
  static const double x16 = 16;
}