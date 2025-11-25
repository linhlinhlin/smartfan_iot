import 'package:flutter/material.dart';

class AppTheme {
  // Vũ trụ trắng - Cosmic White Universe
  static const Color cosmicWhite = Color(0xFFFFFFFF);        // Pure cosmic white
  static const Color nebulaMist = Color(0xFFF8F9FA);         // Subtle nebula mist
  static const Color starfield = Color(0xFFF4F6F8);          // Starfield background
  static const Color cosmicDust = Color(0xFFE8ECF0);         // Cosmic dust particles

  // Deep space elements
  static const Color voidBlack = Color(0xFF0A0A0A);          // Deep space black
  static const Color graphite700 = Color(0xFF2A2F36);        // Stellar graphite
  static const Color graphite500 = Color(0xFF5A6472);        // Nebula graphite

  // Tech rays - Technology light rays
  static const Color techRay = Color(0xFF8AD5FF);            // Ice-blue tech ray
  static const Color quantumBlue = Color(0xFF00BCD4);        // Quantum teal
  static const Color plasmaGlow = Color(0xFF9C27B0);         // Plasma purple

  // Status colors with cosmic theme
  static const Color success = Color(0xFF21C274);            // Stellar green
  static const Color warning = Color(0xFFFFB020);            // Solar yellow
  static const Color error = Color(0xFFF55555);              // Nova red

  // Legacy colors for compatibility
  static const Color baseWhite = cosmicWhite;
  static const Color cosmicMist = starfield;
  static const Color iceBlueAccent = techRay;
  static const Color tealIce = quantumBlue;

  static const double cardRadius = 16.0;
  static const double chipRadius = 12.0;
  static const double elevationCard = 2.0;

  static const double spacingXs = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: starfield,
        colorScheme: ColorScheme.fromSeed(
          seedColor: iceBlueAccent,
          brightness: Brightness.light,
        ).copyWith(
          primary: iceBlueAccent,
          surface: baseWhite,
          onSurface: graphite700,
          secondary: graphite500,
        ),
        cardTheme: CardThemeData(
          color: baseWhite,
          elevation: elevationCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
            side: BorderSide(color: Color(0x10000000), width: 1),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: graphite700,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: graphite700,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Inter',
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: graphite700,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: graphite700,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: graphite700,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: graphite700,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: graphite700,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: graphite700,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: graphite700,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: graphite700,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: graphite700,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: graphite500,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: graphite700,
          ),
          labelMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: graphite700,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: graphite500,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: iceBlueAccent,
            foregroundColor: baseWhite,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(chipRadius),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: iceBlueAccent,
            foregroundColor: baseWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(chipRadius),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: iceBlueAccent),
            foregroundColor: iceBlueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(chipRadius),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(chipRadius),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(chipRadius),
            borderSide: const BorderSide(color: iceBlueAccent, width: 2),
          ),
          filled: true,
          fillColor: baseWhite,
        ),
      );
}