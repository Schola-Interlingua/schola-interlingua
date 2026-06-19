import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';

class MeaningRichText extends StatelessWidget {
  const MeaningRichText({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final String lang = controller.selectedLanguage;
    final TextStyle baseStyle =
        style ??
        Theme.of(context).textTheme.bodyLarge ??
        const TextStyle(fontSize: 16, height: 1.7);
    final List<String> tokens = RegExp(
      r'\w+|\s+|[^\s\w]+',
      unicode: true,
    ).allMatches(text).map((m) => m.group(0)!).toList();

    return Wrap(
      children: tokens.map((String token) {
        final String clean = token
            .replaceAll(RegExp(r'[^\wáéíóúüñ-]', unicode: true), '')
            .toLowerCase();
        final String? translation = controller.resolveMeaning(clean, lang);
        if (translation == null || translation.trim().isEmpty) {
          return Text(token, style: baseStyle);
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (TapDownDetails details) {
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject()! as RenderBox;
            const double popupWidth = 160;
            const double popupHeight = 58;
            const double edgePadding = 12;
            const double gap = 6;

            final double left = math.min(
              math.max(
                edgePadding,
                details.globalPosition.dx - (popupWidth / 2),
              ),
              overlay.size.width - popupWidth - edgePadding,
            );
            final double top = math.max(
              edgePadding,
              details.globalPosition.dy - popupHeight - gap,
            );
            final RelativeRect position = RelativeRect.fromLTRB(
              left,
              top,
              math.max(edgePadding, overlay.size.width - left - popupWidth),
              math.max(edgePadding, overlay.size.height - top - popupHeight),
            );

            showMenu<void>(
              context: context,
              position: position,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF173251)
                  : const Color(0xFFF7FBFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.borderColor(context)),
              ),
              items: <PopupMenuEntry<void>>[
                PopupMenuItem<void>(
                  enabled: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        translation,
                        style: TextStyle(
                          color: AppTheme.textColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(
              token,
              style: baseStyle.copyWith(
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.dotted,
                decorationColor: AppTheme.interactiveTextColor(context),
                color: AppTheme.interactiveTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
