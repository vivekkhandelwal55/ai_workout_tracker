import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color surface = Color(0xFF131313);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF222222);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color primary = Color(0xFFCCFF00);
  static const Color onPrimary = Color(0xFF283500);
  static const Color secondary = Color(0xFFB5D25E);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFAAAAAA);
  static const Color outlineVariant = Color(0xFF444933);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFAA00);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final lexend = GoogleFonts.lexendTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.lexend(fontSize: 56, fontWeight: FontWeight.w700, letterSpacing: -1.12, color: AppColors.onSurface),
      displayMedium: GoogleFonts.lexend(fontSize: 45, fontWeight: FontWeight.w700, letterSpacing: -0.9, color: AppColors.onSurface),
      displaySmall: GoogleFonts.lexend(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -0.72, color: AppColors.onSurface),
      headlineLarge: GoogleFonts.lexend(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      headlineMedium: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      headlineSmall: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface),
      titleLarge: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      titleMedium: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      titleSmall: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
      bodyLarge: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface),
      bodyMedium: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface),
      bodySmall: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
      labelLarge: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.6, color: AppColors.onSurfaceVariant),
      labelMedium: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.6, color: AppColors.onSurfaceVariant),
      labelSmall: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.6, color: AppColors.onSurfaceVariant),
    );

    return base.copyWith(
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: Color(0xFF3A4D00),
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onPrimary,
        secondaryContainer: Color(0xFF2A3500),
        onSecondaryContainer: AppColors.secondary,
        tertiary: Color(0xFF88D8B0),
        onTertiary: Color(0xFF00391E),
        tertiaryContainer: Color(0xFF00522D),
        onTertiaryContainer: Color(0xFFA4F4CA),
        error: AppColors.error,
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: Color(0xFF888888),
        outlineVariant: AppColors.outlineVariant,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppColors.onSurface,
        onInverseSurface: AppColors.surface,
        inversePrimary: AppColors.onPrimary,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: lexend,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          letterSpacing: 2.0,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.4),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outlineVariant, width: 1),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.4),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.6, color: AppColors.onSurfaceVariant),
        hintStyle: GoogleFonts.lexend(fontSize: 14, color: AppColors.surfaceContainerHighest),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: const DividerThemeData(color: Colors.transparent, thickness: 0),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 1.0);
          }
          return GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant, letterSpacing: 1.0);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 22);
          }
          return const IconThemeData(color: AppColors.onSurfaceVariant, size: 22);
        }),
        elevation: 0,
        height: 64,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHighest,
        contentTextStyle: GoogleFonts.lexend(color: AppColors.onSurface),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        side: const BorderSide(color: AppColors.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceContainerHighest,
        linearMinHeight: 2,
      ),
    );
  }
}
