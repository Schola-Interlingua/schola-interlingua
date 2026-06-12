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
        final Map<String, String>? meaning = controller.lookupMeaning(clean);
        final String? translation = controller.resolveMeaning(clean, lang);
        if (meaning == null && translation == null) {
          return Text(token, style: baseStyle);
        }
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (TapDownDetails details) {
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject()! as RenderBox;
            const double popupWidth = 220;
            const double popupHeight = 92;
            const double edgePadding = 12;
            const double gap = 10;

            final double left = math.min(
              math.max(edgePadding, details.globalPosition.dx - (popupWidth / 2)),
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
              color: AppTheme.cardColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: AppTheme.borderColor(context)),
              ),
              items: <PopupMenuEntry<void>>[
                PopupMenuItem<void>(
                  enabled: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        clean,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        translation ?? clean,
                        style: TextStyle(color: AppTheme.textColor(context)),
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
