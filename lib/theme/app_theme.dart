import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Apple Human Interface Guidelines Theme System
/// Based on iOS Design Principles: Clarity, Deference, Depth

class AppTheme {
  // ==================== Colors ====================
  // iOS System Colors
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemYellow = Color(0xFFFFCC00);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemPink = Color(0xFFFF2D55);
  static const Color systemTeal = Color(0xFF5AC8FA);
  static const Color systemIndigo = Color(0xFF5856D6);

  // iOS Gray Scale
  static const Color gray1 = Color(0xFF8E8E93); // System Gray
  static const Color gray2 = Color(0xFFAEAEB2);
  static const Color gray3 = Color(0xFFC7C7CC);
  static const Color gray4 = Color(0xFFD1D1D6);
  static const Color gray5 = Color(0xFFE5E5EA);
  static const Color gray6 = Color(0xFFF2F2F7); // Background

  // Semantic Colors
  static const Color primaryBackground = Color(0xFFF2F2F7); // iOS Gray 6
  static const Color secondaryBackground = Colors.white;
  static const Color groupedBackground = Color(0xFFF2F2F7);
  static const Color separator = Color(0xFFC6C6C8);
  static const Color label = Color(0xFF000000);
  static const Color secondaryLabel = Color(0xFF3C3C43);
  static const Color tertiaryLabel = Color(0x993C3C43); // 60% opacity

  // ==================== Typography ====================
  // iOS Typography Scale
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.37,
    height: 1.2,
  );

  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.36,
    height: 1.2,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.35,
    height: 1.3,
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.38,
    height: 1.3,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.41,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.41,
    height: 1.4,
  );

  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.32,
    height: 1.4,
  );

  static const TextStyle subhead = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.24,
    height: 1.4,
  );

  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.08,
    height: 1.4,
  );

  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.07,
    height: 1.3,
  );

  // ==================== Spacing ====================
  // 8pt Grid System
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // ==================== Border Radius ====================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 20.0;

  // ==================== Elevation/Shadows ====================
  // iOS uses very subtle shadows
  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  // ==================== Theme Data ====================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Tajawal',
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: systemBlue,
        secondary: systemGreen,
        error: systemRed,
        surface: secondaryBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: label,
      ),

      // Scaffold
      scaffoldBackgroundColor: primaryBackground,

      // AppBar Theme (iOS Navigation Bar style)
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: label,
        titleTextStyle: headline.copyWith(color: label),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // Card Theme (Grouped List style)
      cardTheme: CardThemeData(
        color: secondaryBackground,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration Theme (iOS Text Field style)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: gray5, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: gray5, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: systemBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: systemRed, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing12,
        ),
        hintStyle: body.copyWith(color: tertiaryLabel),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: systemBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          minimumSize: const Size(0, 44), // iOS standard button height
          textStyle: headline.copyWith(color: Colors.white),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: systemBlue,
          side: BorderSide(color: systemBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          minimumSize: const Size(0, 44),
          textStyle: headline.copyWith(color: systemBlue),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: systemBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing8,
          ),
          minimumSize: const Size(0, 44),
          textStyle: headline.copyWith(color: systemBlue),
        ),
      ),

      // List Tile Theme (iOS List style)
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing8,
        ),
        minVerticalPadding: spacing8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: separator,
        thickness: 0.5,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: systemBlue,
        size: 24,
      ),

      // Dialog Theme (iOS Alert style)
      dialogTheme: DialogThemeData(
        backgroundColor: secondaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: title3.copyWith(color: label),
        contentTextStyle: body.copyWith(color: secondaryLabel),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: secondaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusLarge),
          ),
        ),
      ),
    );
  }
}

