import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF6F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF1F5);
  static const Color border = Color(0xFFE3E8EF);
  static const Color text = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  // Brand primary (used for primary CTA button)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryMuted = Color(0xFFEEF2FF);

  // Welcome screen CTA/button color (matches design reference)
  static const Color welcomeCta = Color(0xFF1E88E5);
  static const Color warningBg = Color(0xFFFEF9C3);
  static const Color warningText = Color(0xFF92400E);

  // Accent colors (used in Welcome hero cards)
  static const Color success = Color(0xFF22C55E);
  static const Color successMuted = Color(0xFFEAFBF1);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentOrangeMuted = Color(0xFFFFF5E6);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPurpleMuted = Color(0xFFF2EEFF);

  // Welcome background gradient endpoints
  static const Color welcomeBgTop = Color(0xFFF1EEFF);
  static const Color welcomeBgBottom = Color(0xFFFFF5EA);

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: text,
        outline: border,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: const TextStyle(fontWeight: FontWeight.w900, color: text),
        titleMedium: const TextStyle(fontWeight: FontWeight.w800, color: text),
        bodyMedium: const TextStyle(color: text),
        bodySmall: const TextStyle(color: textMuted),
      ),
    );
  }
}
