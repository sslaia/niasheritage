import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors for Dark Theme (Skeuomorphic Wood/Stone - Default)
  static const Color darkBackground = Color(0xFF131313);
  static const Color darkPrimary = Color(0xFFF2CA50);
  static const Color darkPrimaryContainer = Color(0xFFD4AF37);
  static const Color darkOnPrimary = Color(0xFF3C2F00);
  static const Color darkOnPrimaryContainer = Color(0xFF554300);

  static const Color darkSecondary = Color(0xFFFFB68C);
  static const Color darkSecondaryContainer = Color(0xFF753401);
  static const Color darkOnSecondary = Color(0xFF532200);
  static const Color darkOnSecondaryContainer = Color(0xFFFB9F66);

  static const Color darkTertiary = Color(0xFFD0CECB);
  static const Color darkTertiaryContainer = Color(0xFFB4B3B0);
  static const Color darkOnTertiary = Color(0xFF30302F);

  static const Color darkSurface = Color(0xFF131313);
  static const Color darkSurfaceContainer = Color(0xFF1F201F);
  static const Color darkOnSurface = Color(0xFFE4E2E0);
  static const Color darkOnSurfaceVariant = Color(0xFFD0C5AF);
  static const Color darkOutline = Color(0xFF99907C);

  // Colors for Light Theme (Skeuomorphic Warm Stone)
  static const Color lightBackground = Color(0xFFFAF8F5);
  static const Color lightPrimary = Color(0xFF996515);
  static const Color lightPrimaryContainer = Color(0xFFD4AF37);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnPrimaryContainer = Color(0xFF3A2B00);

  static const Color lightSecondary = Color(0xFF753401);
  static const Color lightSecondaryContainer = Color(0xFFFFDBC9);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnSecondaryContainer = Color(0xFF321200);

  static const Color lightTertiary = Color(0xFF4A4A48);
  static const Color lightTertiaryContainer = Color(0xFFE4E2DF);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);

  static const Color lightSurface = Color(0xFFFFFDFB);
  static const Color lightSurfaceContainer = Color(0xFFF0ECE6);
  static const Color lightOnSurface = Color(0xFF2C2C2B);
  static const Color lightOnSurfaceVariant = Color(0xFF5C5850);
  static const Color lightOutline = Color(0xFF99907C);

  static const double unit = 8.0;

  /// Consistent font size and font type for titles in SliverAppBars across the app.
  static TextStyle sliverAppBarTitleStyle({Color color = Colors.white}) =>
      GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
        shadows: const [
          Shadow(
            offset: Offset(0, 1),
            blurRadius: 4.0,
            color: Colors.black54,
          ),
        ],
      );

  /// Consistent font size and font type for subheadings in texts (h2 / section headers).
  static TextStyle subheadingStyle({Color? color}) =>
      GoogleFonts.newsreader(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.3,
      );

  /// Consistent font size and font type for sub-subheadings in texts (h3).
  static TextStyle subSubheadingStyle({Color? color}) =>
      GoogleFonts.newsreader(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.3,
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        secondary: darkSecondary,
        onSecondary: darkOnSecondary,
        secondaryContainer: darkSecondaryContainer,
        onSecondaryContainer: darkOnSecondaryContainer,
        tertiary: darkTertiary,
        onTertiary: darkOnTertiary,
        tertiaryContainer: darkTertiaryContainer,
        surface: darkSurface,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: darkOutline,
      ),
      textTheme: _buildTextTheme(Colors.white, darkOnSurfaceVariant),
      cardTheme: const CardThemeData(
        color: darkSurfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          side: BorderSide(color: darkOutline, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkPrimary),
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        primaryContainer: lightPrimaryContainer,
        onPrimaryContainer: lightOnPrimaryContainer,
        secondary: lightSecondary,
        onSecondary: lightOnSecondary,
        secondaryContainer: lightSecondaryContainer,
        onSecondaryContainer: lightOnSecondaryContainer,
        tertiary: lightTertiary,
        onTertiary: lightOnTertiary,
        tertiaryContainer: lightTertiaryContainer,
        surface: lightSurface,
        onSurface: lightOnSurface,
        onSurfaceVariant: lightOnSurfaceVariant,
        outline: lightOutline,
      ),
      textTheme: _buildTextTheme(lightOnSurface, lightOnSurfaceVariant),
      cardTheme: const CardThemeData(
        color: lightSurfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          side: BorderSide(color: lightOutline, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: lightPrimary),
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: lightOnSurface,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      // Headings & Subheadings - Newsreader
      displayLarge: GoogleFonts.newsreader(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
        color: primaryTextColor,
      ),
      displayMedium: GoogleFonts.newsreader(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
      ),
      displaySmall: GoogleFonts.newsreader(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
      ),
      headlineLarge: GoogleFonts.newsreader(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
      ),
      headlineMedium: GoogleFonts.newsreader(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      headlineSmall: GoogleFonts.newsreader(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      // Subheadings in texts (h2 / section headers) - Newsreader (slightly smaller)
      titleLarge: GoogleFonts.newsreader(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
      ),
      // Sub-subheadings in texts (h3) - Newsreader
      titleMedium: GoogleFonts.newsreader(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      // Minor headings (h4) - Newsreader
      titleSmall: GoogleFonts.newsreader(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),

      // Non-headings (body, labels) - Plus Jakarta Sans application-wide
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primaryTextColor,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primaryTextColor,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondaryTextColor,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
        color: secondaryTextColor,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
    );
  }
}
