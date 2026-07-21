// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: App color palette and theme extension for light and dark colors.
// First Written on: Sunday, 07-Jun-2026
// Edited on: Tuesday, 14-Jul-2026
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color bottomNavigationBar = Color(0xFF648A9E);

  static const Color expiredFill = Color(0xFFF6D3D3);
  static const Color expiredBorder = Color(0xFFE9ACAC);

  static const Color expiringTomorrowFill = Color(0xFFF4DBB7);
  static const Color expiringTomorrowBorder = Color(0xFFE6B875);

  static const Color expiringInFiveDaysFill = Color(0xFFF5EEAE);
  static const Color expiringInFiveDaysBorder = Color(0xFFDED57C);

  static const Color freshFill = Color(0xFFD1F7CF);
  static const Color freshBorder = Color(0xFF98E094);

  static const Color categoryActiveFill = Color(0xFFCFE4EE);
  static const Color categoryActiveBorder = Color(0xFF98C1D6);

  static const Color categoryInactiveFill = Color(0xFFF2EFEF);
  static const Color categoryInactiveBorder = Color(0xFFC3C2C2);

  static const Color textDark = Color(0xFF111111);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9FAFB);
  static const Color cardBackground = Color(0xFFFFFFFF);
}

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color primary;
  final Color primarySoft;
  final Color primaryBorder;

  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color card;
  final Color border;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textOnPrimary;

  final Color danger;
  final Color dangerSoft;
  final Color dangerBorder;

  final Color warning;
  final Color warningSoft;
  final Color warningBorder;

  final Color success;
  final Color successSoft;
  final Color successBorder;

  final Color chipSelected;
  final Color chipSelectedBorder;
  final Color chipUnselected;
  final Color chipUnselectedBorder;

  final Color shadow;

  const AppThemeColors({
    required this.primary,
    required this.primarySoft,
    required this.primaryBorder,
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textOnPrimary,
    required this.danger,
    required this.dangerSoft,
    required this.dangerBorder,
    required this.warning,
    required this.warningSoft,
    required this.warningBorder,
    required this.success,
    required this.successSoft,
    required this.successBorder,
    required this.chipSelected,
    required this.chipSelectedBorder,
    required this.chipUnselected,
    required this.chipUnselectedBorder,
    required this.shadow,
  });

  static const AppThemeColors light = AppThemeColors(
    primary: Color(0xFF2F7A94),
    primarySoft: Color(0xFFDCEEF3),
    primaryBorder: Color(0xFF8FC7D6),
    background: Color(0xFFF7FAFB),
    surface: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFF0F4F6),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE6EBEE),
    textPrimary: Color(0xFF1B2430),
    textSecondary: Color(0xFF5B6572),
    textMuted: Color(0xFF8D96A0),
    textOnPrimary: Color(0xFFFFFFFF),
    danger: Color(0xFFE15B5B),
    dangerSoft: Color(0xFFFBE6E6),
    dangerBorder: Color(0xFFF0B3B3),
    warning: Color(0xFFC98A2E),
    warningSoft: Color(0xFFFBEAD1),
    warningBorder: Color(0xFFEFCB93),
    success: Color(0xFF3F9D5D),
    successSoft: Color(0xFFDFF5E4),
    successBorder: Color(0xFFA8E0B7),
    chipSelected: Color(0xFFDCEEF3),
    chipSelectedBorder: Color(0xFF8FC7D6),
    chipUnselected: Color(0xFFF0F0F1),
    chipUnselectedBorder: Color(0xFFD6D6D8),
    shadow: Color(0x14162836),
  );

  static const AppThemeColors dark = AppThemeColors(
    primary: Color(0xFF7FD0E3),
    primarySoft: Color(0xFF1E3940),
    primaryBorder: Color(0xFF4C818F),

    background: Color(0xFF141A1F),
    surface: Color(0xFF1C242B),
    surfaceSoft: Color(0xFF242E35),
    card: Color(0xFF1F2830),
    border: Color(0xFF333E46),

    textPrimary: Color(0xFFF2F6F8),
    textSecondary: Color(0xFFC7D1D6),
    textMuted: Color(0xFF8E9BA3),
    textOnPrimary: Color(0xFF0E1A1F),

    danger: Color(0xFFFF9E9E),
    dangerSoft: Color(0xFF4A2A2D),
    dangerBorder: Color(0xFF8C4F53),

    warning: Color(0xFFFFD08A),
    warningSoft: Color(0xFF4C3B22),
    warningBorder: Color(0xFF93713D),

    success: Color(0xFF9EE6AC),
    successSoft: Color(0xFF22402A),
    successBorder: Color(0xFF548A5E),

    chipSelected: Color(0xFF25444C),
    chipSelectedBorder: Color(0xFF57838F),
    chipUnselected: Color(0xFF242E35),
    chipUnselectedBorder: Color(0xFF3D4A52),

    shadow: Color(0x40000000),
  );

  @override
  AppThemeColors copyWith({
    Color? primary,
    Color? primarySoft,
    Color? primaryBorder,
    Color? background,
    Color? surface,
    Color? surfaceSoft,
    Color? card,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textOnPrimary,
    Color? danger,
    Color? dangerSoft,
    Color? dangerBorder,
    Color? warning,
    Color? warningSoft,
    Color? warningBorder,
    Color? success,
    Color? successSoft,
    Color? successBorder,
    Color? chipSelected,
    Color? chipSelectedBorder,
    Color? chipUnselected,
    Color? chipUnselectedBorder,
    Color? shadow,
  }) {
    return AppThemeColors(
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      primaryBorder: primaryBorder ?? this.primaryBorder,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      card: card ?? this.card,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      warningBorder: warningBorder ?? this.warningBorder,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      successBorder: successBorder ?? this.successBorder,
      chipSelected: chipSelected ?? this.chipSelected,
      chipSelectedBorder: chipSelectedBorder ?? this.chipSelectedBorder,
      chipUnselected: chipUnselected ?? this.chipUnselected,
      chipUnselectedBorder: chipUnselectedBorder ?? this.chipUnselectedBorder,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      primaryBorder: Color.lerp(primaryBorder, other.primaryBorder, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      dangerBorder: Color.lerp(dangerBorder, other.dangerBorder, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      successBorder: Color.lerp(successBorder, other.successBorder, t)!,
      chipSelected: Color.lerp(chipSelected, other.chipSelected, t)!,
      chipSelectedBorder: Color.lerp(
        chipSelectedBorder,
        other.chipSelectedBorder,
        t,
      )!,
      chipUnselected: Color.lerp(chipUnselected, other.chipUnselected, t)!,
      chipUnselectedBorder: Color.lerp(
        chipUnselectedBorder,
        other.chipUnselectedBorder,
        t,
      )!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppThemeColorsX on BuildContext {
  AppThemeColors get appColors {
    return Theme.of(this).extension<AppThemeColors>()!;
  }

  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }
}
