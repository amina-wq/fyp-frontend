import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const Color _lightPrimary = Color(0xFF648A9E);
  static const Color _darkPrimary = Color(0xFF8DB8CE);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _lightPrimary,
      primary: _lightPrimary,
      surface: AppThemeColors.light.surface,
    );

    return _baseTheme(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      colors: AppThemeColors.light,
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _darkPrimary,
      brightness: Brightness.dark,
      primary: _darkPrimary,
      surface: AppThemeColors.dark.surface,
    );

    return _baseTheme(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      colors: AppThemeColors.dark,
    );
  }

  static ThemeData _baseTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required AppThemeColors colors,
  }) {
    final isDark = brightness == Brightness.dark;

    final textTheme = _textTheme(colors);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.background,
      colorScheme: colorScheme,
      fontFamily: 'MarkPro',
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 22,
          fontFamily: 'MarkPro',
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primarySoft,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.primary);
          }

          return IconThemeData(color: colors.textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            );
          }

          return TextStyle(
            color: colors.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.card,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          fontFamily: 'MarkPro',
        ),
        contentTextStyle: TextStyle(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          fontFamily: 'MarkPro',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? const Color(0xFF27313A)
            : const Color(0xFF1F2147),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontFamily: 'MarkPro',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }

          return colors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primarySoft;
          }

          return colors.surfaceSoft;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.chipUnselected,
        selectedColor: colors.chipSelected,
        disabledColor: colors.surfaceSoft,
        checkmarkColor: colors.primary,
        side: BorderSide(color: colors.chipUnselectedBorder),
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontWeight: FontWeight.w800,
          fontFamily: 'MarkPro',
        ),
        secondaryLabelStyle: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w900,
          fontFamily: 'MarkPro',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSoft,
        hintStyle: TextStyle(
          color: colors.textMuted,
          fontWeight: FontWeight.w600,
        ),
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.textOnPrimary,
          disabledBackgroundColor: colors.surfaceSoft,
          disabledForegroundColor: colors.textMuted,
          elevation: 0,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontFamily: 'MarkPro',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontFamily: 'MarkPro',
          ),
        ),
      ),
      iconTheme: IconThemeData(color: colors.primary),
      dividerTheme: DividerThemeData(color: colors.border),
      listTileTheme: ListTileThemeData(
        textColor: colors.textPrimary,
        iconColor: colors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static TextTheme _textTheme(AppThemeColors colors) {
    return TextTheme(
      displayLarge: TextStyle(color: colors.textPrimary),
      displayMedium: TextStyle(color: colors.textPrimary),
      displaySmall: TextStyle(color: colors.textPrimary),
      headlineLarge: TextStyle(color: colors.textPrimary),
      headlineMedium: TextStyle(color: colors.textPrimary),
      headlineSmall: TextStyle(color: colors.textPrimary),
      titleLarge: TextStyle(
        color: colors.textPrimary,
        fontWeight: FontWeight.w900,
      ),
      titleMedium: TextStyle(
        color: colors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      titleSmall: TextStyle(
        color: colors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      labelLarge: TextStyle(
        color: colors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      labelMedium: TextStyle(
        color: colors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: TextStyle(
        color: colors.textMuted,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        color: colors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      bodySmall: TextStyle(
        color: colors.textMuted,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

final ThemeData themeData = AppTheme.lightTheme;
