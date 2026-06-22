import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 48,
    this.radius,
    this.padding,
    this.assetPath = 'assets/images/logo_foreground.png',
  });

  final double size;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final double resolvedRadius = radius ?? size * 0.24;

    return Container(
      width: size,
      height: size,
      padding: padding ?? EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(resolvedRadius),
        color: AppTheme.primaryDark,
        border: Border.all(
          color: Colors.white.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.18
                : 0.34,
          ),
        ),
        boxShadow: AppTheme.glassShadow(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(resolvedRadius * 0.72),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }
}
