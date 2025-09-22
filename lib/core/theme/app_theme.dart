import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Scheme as per PRD
  static const Color primaryNavyBlue = Color(0xFF1E3A8A);
  static const Color secondaryWhite = Color(0xFFFFFFFF);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color successGreen = Color(0xFF28A745);
  static const Color errorRed = Color(0xFFDC3545);
  static const Color warningYellow = Color(0xFFFFC107);
  
  // Additional colors for UI
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF757575);
  static const Color mediumGrey = Color(0xFFBDBDBD);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavyBlue,
        primary: primaryNavyBlue,
        secondary: accentGold,
        surface: secondaryWhite,
        error: errorRed,
      ),
      
      // Typography using educational-friendly font
      textTheme: GoogleFonts.openSansTextTheme().copyWith(
        // Headings
        headlineLarge: GoogleFonts.openSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryNavyBlue,
        ),
        headlineMedium: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryNavyBlue,
        ),
        
        // Body Text
        bodyLarge: GoogleFonts.openSans(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: GoogleFonts.openSans(
          fontSize: 14,
          color: Colors.black87,
        ),
        
        // Captions
        bodySmall: GoogleFonts.openSans(
          fontSize: 12,
          color: darkGrey,
        ),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryNavyBlue,
        foregroundColor: secondaryWhite,
        elevation: 0,
        titleTextStyle: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: secondaryWhite,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavyBlue,
          foregroundColor: secondaryWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.openSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavyBlue,
          side: const BorderSide(color: primaryNavyBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.openSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryNavyBlue, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mediumGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryNavyBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.openSans(
          color: darkGrey,
          fontSize: 16,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: secondaryWhite,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondaryWhite,
        selectedItemColor: primaryNavyBlue,
        unselectedItemColor: darkGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

// Extension for custom button styles
extension AppButtonStyles on ThemeData {
  ButtonStyle get goldButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppTheme.accentGold,
    foregroundColor: AppTheme.primaryNavyBlue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: GoogleFonts.openSans(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
  
  ButtonStyle get successButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppTheme.successGreen,
    foregroundColor: AppTheme.secondaryWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: GoogleFonts.openSans(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
  
  ButtonStyle get errorButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppTheme.errorRed,
    foregroundColor: AppTheme.secondaryWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: GoogleFonts.openSans(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}