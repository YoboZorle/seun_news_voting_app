import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors - Light theme
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryDarkOrange = Color(0xFFE55100);
  static const Color primaryLightOrange = Color(0xFFFFB366);

  // Background colors - Light
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color lightBg = Color(0xFFFAFBFC);
  static const Color surfaceBg = Color(0xFFFFFFFF);
  static const Color secondaryBg = Color(0xFFF0F2F5);

  // Text colors
  static const Color textPrimary = Color(0xFF0D1117);
  static const Color textSecondary = Color(0xFF57606A);
  static const Color textAccent = Color(0xFF0969DA);

  // Status colors
  static const Color success = Color(0xFF1A7F37);
  static const Color warning = Color(0xB3D1500B);
  static const Color error = Color(0xFFD1242F);
  static const Color info = Color(0xFF0969DA);

  // Get theme data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Primary color scheme
      primaryColor: primaryOrange,
      primarySwatch: _createMaterialColor(primaryOrange),

      // Color scheme
      colorScheme: ColorScheme.light(
        primary: primaryOrange,
        primaryContainer: primaryDarkOrange,
        secondary: primaryLightOrange,
        secondaryContainer: Color(0xFFFFEAD4),
        tertiary: textAccent,
        surface: surfaceBg,
        surfaceVariant: secondaryBg,
        background: lightBg,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: lightBg,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceBg,
        foregroundColor: textPrimary,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(
          color: primaryOrange,
          size: 24,
        ),
        shadowColor: Colors.black.withOpacity(0.05),
      ),

      // Card
      cardTheme: CardThemeData(
        color: surfaceBg,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: secondaryBg,
            width: 1,
          ),
        ),
        shadowColor: Colors.black.withOpacity(0.08),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceBg,
        selectedItemColor: primaryOrange,
        unselectedItemColor: textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primaryOrange,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),

      // Button styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryOrange,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: BorderSide(color: primaryOrange, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryBg,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondaryBg),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondaryBg),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryOrange, width: 2),
        ),
        labelStyle: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),

      // Text themes
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: secondaryBg,
        thickness: 1,
        space: 1,
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: primaryOrange,
        size: 24,
      ),
    );
  }

  // Create a MaterialColor from a single color
  static MaterialColor _createMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;

    final Map<int, Color> shades = {
      50: Color.fromARGB(255, red + (255 - red) ~/ 10, green + (255 - green) ~/ 10, blue + (255 - blue) ~/ 10),
      100: Color.fromARGB(255, red + (255 - red) ~/ 5, green + (255 - green) ~/ 5, blue + (255 - blue) ~/ 5),
      200: Color.fromARGB(255, red + (255 - red) ~/ 3, green + (255 - green) ~/ 3, blue + (255 - blue) ~/ 3),
      300: Color.fromARGB(255, red + (255 - red) ~/ 2, green + (255 - green) ~/ 2, blue + (255 - blue) ~/ 2),
      400: Color.fromARGB(255, (red + 255) ~/ 2, (green + 255) ~/ 2, (blue + 255) ~/ 2),
      500: color,
      600: Color.fromARGB(255, (red * 9) ~/ 10, (green * 9) ~/ 10, (blue * 9) ~/ 10),
      700: Color.fromARGB(255, (red * 8) ~/ 10, (green * 8) ~/ 10, (blue * 8) ~/ 10),
      800: Color.fromARGB(255, (red * 7) ~/ 10, (green * 7) ~/ 10, (blue * 7) ~/ 10),
      900: Color.fromARGB(255, (red * 6) ~/ 10, (green * 6) ~/ 10, (blue * 6) ~/ 10),
    };

    return MaterialColor(color.value, shades);
  }
}