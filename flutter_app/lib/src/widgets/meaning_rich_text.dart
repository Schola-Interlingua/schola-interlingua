import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';

Future<void> showWordMeaningMenu({
  required BuildContext context,
  required Offset globalPosition,
  required String word,
}) async {
  final AppController controller = AppStateScope.of(context);
  final String clean = word
      .replaceAll(RegExp(r'[^\wáéíóúüñ-]', unicode: true), '')
      .toLowerCase();
  final String? translation = controller.resolveMeaning(
    clean,
    controller.selectedLanguage,
  );
  if (translation == null || translation.trim().isEmpty) {
    return;
  }

  final bool isFavorite = controller.isFavoriteWord(clean);
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject()! as RenderBox;
  const double popupWidth = 232;
  const double popupHeight = 66;
  const double edgePadding = 12;
  const double gap = 6;

  final double left = math.min(
    math.max(edgePadding, globalPosition.dx - (popupWidth / 2)),
    overlay.size.width - popupWidth - edgePadding,
  );
  final double top = math.max(
    edgePadding,
    globalPosition.dy - popupHeight - gap,
  );
  final RelativeRect position = RelativeRect.fromLTRB(
    left,
    top,
    math.max(edgePadding, overlay.size.width - left - popupWidth),
    math.max(edgePadding, overlay.size.height - top - popupHeight),
  );

  await showMenu<void>(
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: SizedBox(
          width: 190,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  translation,
                  style: TextStyle(
                    color: AppTheme.textColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                key: ValueKey<String>('favorite-word-$clean'),
                onPressed: () {
                  controller.toggleFavoriteWord(clean);
                  Navigator.of(context).pop();
                },
                tooltip: isFavorite
                    ? 'Retirar del favoritos'
                    : 'Adder al favoritos',
                style: IconButton.styleFrom(
                  backgroundColor: isFavorite
                      ? const Color(0xFFE54867).withValues(alpha: 0.16)
                      : AppTheme.surfaceVariant(context),
                  side: BorderSide(
                    color: isFavorite
                        ? const Color(0xFFE54867)
                        : AppTheme.borderColor(context),
                  ),
                  minimumSize: const Size(34, 34),
                  maximumSize: const Size(34, 34),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 19,
                  color: isFavorite
                      ? const Color(0xFFE54867)
                      : AppTheme.mutedTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

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
            showWordMeaningMenu(
              context: context,
              globalPosition: details.globalPosition,
              word: clean,
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
