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
    primary: Color(0xFF648A9E),
    primarySoft: Color(0xFFCFE4EE),
    primaryBorder: Color(0xFF98C1D6),
    background: Color(0xFFF9FAFB),
    surface: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFF2F6F8),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE3E8EC),
    textPrimary: Color(0xFF1F2147),
    textSecondary: Color(0xFF5D6470),
    textMuted: Color(0xFF8A919C),
    textOnPrimary: Color(0xFFFFFFFF),
    danger: Color(0xFFD46A6A),
    dangerSoft: Color(0xFFF6D3D3),
    dangerBorder: Color(0xFFE9ACAC),
    warning: Color(0xFFB88632),
    warningSoft: Color(0xFFF4DBB7),
    warningBorder: Color(0xFFE6B875),
    success: Color(0xFF4F9B4C),
    successSoft: Color(0xFFD1F7CF),
    successBorder: Color(0xFF98E094),
    chipSelected: Color(0xFFCFE4EE),
    chipSelectedBorder: Color(0xFF98C1D6),
    chipUnselected: Color(0xFFF2EFEF),
    chipUnselectedBorder: Color(0xFFC3C2C2),
    shadow: Color(0x14000000),
  );

  static const AppThemeColors dark = AppThemeColors(
    primary: Color(0xFF9FC7D8),
    primarySoft: Color(0xFF263F4A),
    primaryBorder: Color(0xFF4D7180),

    background: Color(0xFF172026),
    surface: Color(0xFF202A31),
    surfaceSoft: Color(0xFF2A353D),
    card: Color(0xFF222D34),
    border: Color(0xFF3A4851),

    textPrimary: Color(0xFFF4F8FA),
    textSecondary: Color(0xFFD0DAE0),
    textMuted: Color(0xFF9BA8B0),
    textOnPrimary: Color(0xFF102027),

    danger: Color(0xFFFFA6A6),
    dangerSoft: Color(0xFF553033),
    dangerBorder: Color(0xFF9A5A5F),

    warning: Color(0xFFFFD99A),
    warningSoft: Color(0xFF564328),
    warningBorder: Color(0xFF9C7946),

    success: Color(0xFFA9E8A7),
    successSoft: Color(0xFF294D2F),
    successBorder: Color(0xFF5B955F),

    chipSelected: Color(0xFF2B4652),
    chipSelectedBorder: Color(0xFF5E8798),
    chipUnselected: Color(0xFF2A353D),
    chipUnselectedBorder: Color(0xFF46545E),

    shadow: Color(0x52000000),
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
