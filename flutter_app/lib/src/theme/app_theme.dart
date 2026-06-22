import 'dart:ui';

import 'package:flutter/material.dart';

final class AppTheme {
  static const Color primary = Color(0xFF0A2F57);
  static const Color primaryLight = Color(0xFF1A5D96);
  static const Color primaryDark = Color(0xFF061C33);
  static const Color background = Color(0xFFEAF2FF);
  static const Color backgroundSecondary = Color(0xFFF4F8FF);
  static const Color text = Color(0xFF18314E);
  static const Color textMuted = Color(0xFF5E7693);
  static const Color card = Color(0x99FFFFFF);
  static const Color border = Color(0x80FFFFFF);
  static const Color darkBackground = Color(0xFF07111D);
  static const Color darkBackgroundSecondary = Color(0xFF102238);
  static const Color darkCard = Color(0x66152940);
  static const Color darkText = Color(0xFFEAF3FF);
  static const Color darkTextMuted = Color(0xFFABC0D8);
  static const Color darkBorder = Color(0x4DAFD1FF);
  static const Color glowBlue = Color(0x8048B2FF);
  static const Color glowCyan = Color(0x6658E0FF);

  static ThemeData light() {
    const ColorScheme scheme = ColorScheme.light(
      primary: primary,
      secondary: primaryLight,
      surface: card,
      onSurface: text,
      onPrimary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      dividerColor: border,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: border),
        ),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: Colors.transparent),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary.withValues(alpha: 0.94),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: const BorderSide(color: border),
          backgroundColor: Colors.white.withValues(alpha: 0.14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.22),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w600,
          color: text,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: text,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: text, height: 1.7),
        bodyMedium: TextStyle(fontSize: 15, color: text, height: 1.6),
        bodySmall: TextStyle(fontSize: 14, color: textMuted, height: 1.5),
      ),
    );
  }

  static ThemeData dark() {
    const ColorScheme scheme = ColorScheme.dark(
      primary: primary,
      secondary: primaryLight,
      surface: darkCard,
      onSurface: darkText,
      onPrimary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: darkBackground,
      canvasColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: Colors.transparent),
      cardTheme: CardThemeData(
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      dividerColor: darkBorder,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          foregroundColor: darkText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkText,
          side: const BorderSide(color: darkBorder),
          backgroundColor: Colors.white.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(color: darkTextMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: glowBlue, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w600,
          color: darkText,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: darkText,
          height: 1.25,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: darkText, height: 1.7),
        bodyMedium: TextStyle(fontSize: 15, color: darkText, height: 1.6),
        bodySmall: TextStyle(fontSize: 14, color: darkTextMuted, height: 1.5),
      ),
      iconTheme: const IconThemeData(color: darkText),
    );
  }

  static Color surfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkBackgroundSecondary
      : backgroundSecondary;

  static Color borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : border;

  static Color textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkText : text;

  static Color mutedTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTextMuted
      : textMuted;

  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : card;

  static Color interactiveTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF8BC8FF)
      : primary;

  static Color successBannerBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0x3347D98A)
      : const Color(0xCCDBF6E5);

  static Color successBannerBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xAA6EF0B1)
      : const Color(0x9937B56F);

  static Color successBannerText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFD9FFE8)
      : const Color(0xFF156C2F);

  static List<BoxShadow> glassShadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const <BoxShadow>[
          BoxShadow(
            color: Color(0x66020B16),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0x331F7DD8),
            blurRadius: 10,
            offset: Offset(0, 0),
          ),
        ]
      : const <BoxShadow>[
          BoxShadow(
            color: Color(0x220F2E52),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x1AFFFFFF),
            blurRadius: 8,
            offset: Offset(0, 0),
          ),
        ];
}

class ScholaCard extends StatelessWidget {
  const ScholaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(32),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(28);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: borderRadius,
            border: Border.all(color: AppTheme.borderColor(context)),
            boxShadow: AppTheme.glassShadow(context),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? <Color>[
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.03),
                    ]
                  : <Color>[
                      Colors.white.withValues(alpha: 0.74),
                      Colors.white.withValues(alpha: 0.46),
                    ],
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
