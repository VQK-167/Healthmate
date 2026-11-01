import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF2E8B68);
  static const background = Color(0xFFF4F8F5);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFEAF4EF);
  static const textPrimary = Color(0xFF17352D);
  static const textSecondary = Color(0xFF6E847C);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: Color(0xFF76C7A5),
      onSecondary: Color(0xFF17352D),
      surface: surface,
      onSurface: textPrimary,
      error: Color(0xFFD85D5D),
    ),
    scaffoldBackgroundColor: background,
    canvasColor: background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Color(0xFFD7F1E4),
      height: 76,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceElevated,
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textSecondary),
      prefixIconColor: textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFDCE9E2)),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceElevated,
      contentTextStyle: const TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: surface,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: Color(0xFFD7E9DF),
    ),
  );
}
