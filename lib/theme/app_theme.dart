import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF6F00);
  static const Color lightOrange = Color(0xFFFFB300);
  static const Color backgroundLight = Color(0xFFF8FBF8);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1B2128);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color dividerColor = Color(0xFFE5E7EB);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF388E3C);

  static const Color vendorPrimary = Color(0xFF1B5E20);
  static const Color customerPrimary = Color(0xFF2E7D32);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: accentOrange,
      surface: cardWhite,
      background: backgroundLight,
      error: errorRed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        backgroundColor: cardWhite,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: textDark),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: dividerColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        labelStyle: const TextStyle(
          color: textGrey,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Color(0xFF9CA3AF),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        selectedColor: primaryGreen.withOpacity(0.15),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Text Styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppTheme.textDark,
    fontFamily: 'Poppins',
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppTheme.textDark,
    fontFamily: 'Poppins',
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppTheme.textDark,
    fontFamily: 'Poppins',
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.textGrey,
    fontFamily: 'Poppins',
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.textDark,
    fontFamily: 'Poppins',
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppTheme.textGrey,
    fontFamily: 'Poppins',
  );

  static const TextStyle price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppTheme.primaryGreen,
    fontFamily: 'Poppins',
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );
}
