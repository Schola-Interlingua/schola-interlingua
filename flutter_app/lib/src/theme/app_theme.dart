import 'package:flutter/material.dart';

final class AppTheme {
  static const Color primary = Color(0xFF082743);
  static const Color primaryLight = Color(0xFF0D3A5F);
  static const Color primaryDark = Color(0xFF051A2A);
  static const Color background = Color(0xFFFAFBFC);
  static const Color backgroundSecondary = Color(0xFFF8F9FA);
  static const Color text = Color(0xFF2C3E50);
  static const Color textMuted = Color(0xFF6C757D);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE9ECEF);
  static const Color darkBackground = Color(0xFF0D1724);
  static const Color darkBackgroundSecondary = Color(0xFF132235);
  static const Color darkCard = Color(0xFF162538);
  static const Color darkText = Color(0xFFE7EEF7);
  static const Color darkTextMuted = Color(0xFFAEBFD1);
  static const Color darkBorder = Color(0xFF29405C);

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
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: card,
        margin: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
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
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkCard,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        margin: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      dividerColor: darkBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBackgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(color: darkTextMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
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
      Theme.of(context).brightness == Brightness.dark ? darkTextMuted : textMuted;

  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : card;

  static Color interactiveTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF8BC8FF)
      : primary;
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
    return Card(
      child: Padding(padding: padding, child: child),
    );
  }
}
