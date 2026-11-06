import 'package:flutter/material.dart';

/// PillCare colour palette (taken from the design reference).
class PC {
  static const navy = Color(0xFF0E2550); // deep navy (sidebar / headings)
  static const primary = Color(0xFF1E3F9E); // royal blue (buttons, accents)
  static const bg = Color(0xFFF0F5F9); // page background
  static const card = Colors.white;
  static const border = Color(0xFFE3E9F0);
  static const text = Color(0xFF1B2437);
  static const muted = Color(0xFF7A8699);

  static const green = Color(0xFF2E9E6B);
  static const red = Color(0xFFD9534F);
  static const amber = Color(0xFFE0922F);
  static const purple = Color(0xFF8A6BB8);

  // Soft tinted tiles
  static const greenTint = Color(0xFFE6F5EC);
  static const redTint = Color(0xFFFEE5E2);
  static const amberTint = Color(0xFFFFF3E4);
  static const purpleTint = Color(0xFFF3EEF7);
  static const blueTint = Color(0xFFF1F5FE);

  // Time-of-day tints
  static const morning = Color(0xFFFFF3D7);
  static const afternoon = Color(0xFFFFE6CB);
  static const evening = Color(0xFFE7F1FD);

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: card,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: navy,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: card),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: const Color(0xFFDCE6FB),
        backgroundColor: card,
        side: const BorderSide(color: border),
        labelStyle: const TextStyle(color: text),
        secondaryLabelStyle: const TextStyle(color: navy),
        checkmarkColor: navy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        selectedColor: navy,
        selectedTileColor: blueTint,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? green : null,
        ),
      ),
    );
  }
}
