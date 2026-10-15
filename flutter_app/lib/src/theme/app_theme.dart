import 'package:flutter/material.dart';

final class AppTheme {
  static const Color primary = Color(0xFF0A2F57);
  static const Color primaryLight = Color(0xFF1A5D96);
  static const Color primaryDark = Color(0xFF061C33);
  static const Color background = Color(0xFFF3F5F8);
  static const Color backgroundSecondary = Color(0xFFF7F9FC);
  static const Color text = Color(0xFF18314E);
  static const Color textMuted = Color(0xFF52647A);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFDCE3ED);
  static const Color darkBackground = Color(0xFF0C1420);
  static const Color darkBackgroundSecondary = Color(0xFF182638);
  static const Color darkCard = Color(0xFF121F30);
  static const Color darkText = Color(0xFFEAF3FF);
  static const Color darkTextMuted = Color(0xFFABC0D8);
  static const Color darkBorder = Color(0xFF2A3B50);
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
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: border),
        ),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: Colors.transparent),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary.withValues(alpha: 0.94),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryLight),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: const BorderSide(color: border),
          backgroundColor: Colors.white.withValues(alpha: 0.14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w600,
          color: text,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
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
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      dividerColor: darkBorder,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF92C5FF),
          foregroundColor: primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF8BC8FF)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkText,
          side: const BorderSide(color: darkBorder),
          backgroundColor: Colors.white.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: glowBlue, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w600,
          color: darkText,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
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

  static List<BoxShadow> glassShadow(BuildContext context) => <BoxShadow>[
    BoxShadow(
      color: Colors.black.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.035,
      ),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

class ScholaCard extends StatelessWidget {
  const ScholaCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(compact ? 18 : 22),
        border: Border.all(color: AppTheme.borderColor(context)),
        boxShadow: AppTheme.glassShadow(context),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: padding ?? EdgeInsets.all(compact ? 20 : 28),
          child: child,
        ),
      ),
    );
  }
}
