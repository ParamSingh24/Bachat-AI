import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors as specified in DESIGN.md
  static const Color primary = Color(0xFF6834EB);
  static const Color primaryContainer = Color(0xFFC8B7FF);
  static const Color primaryDim = Color(0xFF5C20DF);
  
  static const Color secondary = Color(0xFF006E2A);
  
  static const Color surface = Color(0xFFF8F9FE);
  static const Color surfaceContainerLow = Color(0xFFF1F3F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  
  static const Color onSurface = Color(0xFF2D333A);
  static const Color outlineVariant = Color(0xFFADB2BB);
  static const Color onPrimary = Color(0xFFFDF7FF);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        surface: surface,
        onSurface: onSurface,
        onPrimary: onPrimary,
        outlineVariant: outlineVariant,
      ),
      textTheme: TextTheme(
        // Plus Jakarta Sans for Display/Headlines
        displayLarge: GoogleFonts.plusJakartaSans(
          color: onSurface,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          color: onSurface,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          color: onSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: onSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          color: onSurface,
          fontWeight: FontWeight.w600,
        ),
        // Manrope for Body/Labels
        bodyLarge: GoogleFonts.manrope(
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.manrope(
          color: onSurface,
        ),
        bodySmall: GoogleFonts.manrope(
          color: onSurface,
        ),
        labelLarge: GoogleFonts.manrope(
          color: onSurface,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: GoogleFonts.manrope(
          color: onSurface,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.manrope(
          color: onSurface,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // xl roundedness
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
        ),
      ),
      cardTheme: const CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.only(bottom: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: const UnderlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4), // sm
            topRight: Radius.circular(4),
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceContainerLowest.withOpacity(0.9), // Glassmorphism idea
        elevation: 0,
        selectedItemColor: primary,
        unselectedItemColor: outlineVariant,
      ),
    );
  }
}
