import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
      ),
      textTheme: TextTheme(
        // metric-lg
        displayLarge: GoogleFonts.manrope(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          height: 56 / 48,
          letterSpacing: -0.02 * 48,
          color: AppColors.onSurface,
        ),
        // metric-md
        displayMedium: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 40 / 32,
          letterSpacing: -0.01 * 32,
          color: AppColors.onSurface,
        ),
        // headline-lg
        headlineLarge: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 32 / 24,
          color: AppColors.onSurface,
        ),
        // headline-md
        headlineMedium: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 28 / 20,
          color: AppColors.onSurface,
        ),
        // title-sm
        titleSmall: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 24 / 16,
          color: AppColors.onSurface,
        ),
        // body-lg
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          color: AppColors.onSurfaceVariant,
        ),
        // body-md
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: AppColors.onSurfaceVariant,
        ),
        // label-bold
        labelLarge: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 16 / 12,
          letterSpacing: 0.05 * 12,
          color: AppColors.onSurface,
        ),
        // label-muted
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 16 / 12,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
