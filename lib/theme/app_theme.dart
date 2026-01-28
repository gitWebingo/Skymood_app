import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Elegant Night/Background Gradient (Main Theme)
  static const LinearGradient elegantBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E335A), // Deep Purple-Blue
      Color(0xFF1C1B33), // Darker Navy
    ],
  );

  // Variations for WeatherBackground compatibility, but tuned to the new theme
  static const LinearGradient sunnyDay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A3D70), Color(0xFF2E335A)], // Slightly lighter top
  );

  static const LinearGradient rainyDay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2C2D4A), Color(0xFF1F2036)], // Darker/Desaturated
  );

  static const LinearGradient cloudyDay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF35395E), Color(0xFF242642)],
  );

  static const LinearGradient stormyDay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF252642), Color(0xFF161626)],
  );

  static const LinearGradient snowyDay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF454975), Color(0xFF2E335A)],
  );

  static const LinearGradient night = elegantBackground;

  static const Color accentColor = Color(0xFFDDB130);
  static const Color activeTabColor = Color.fromARGB(255, 149, 122, 255);

  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white54 = Colors.white54;
  static const Color white30 = Colors.white30;
  static const Color white12 = Colors.white12;
}

class AppTextStyles {
  // Ultra-thin/Modern Look
  static TextStyle get headlineLarge => GoogleFonts.outfit(
        fontSize: 64,
        fontWeight: FontWeight.w200,
        color: AppColors.white,
        letterSpacing: -1.0,
      );

  static TextStyle get headlineMedium => GoogleFonts.outfit(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      );

  static TextStyle get titleLarge => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get titleMedium => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.white70,
      );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.white,
      );

  static TextStyle get bodySmall => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.normal, // Regular weight for small text
        color: AppColors.white54,
      );
}
