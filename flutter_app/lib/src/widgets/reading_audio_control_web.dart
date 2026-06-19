import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ReadingAudioControl extends StatelessWidget {
  const ReadingAudioControl({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.volume_up_outlined,
              color: AppTheme.mutedTextColor(context),
            ),
            const SizedBox(width: 10),
            Text(
              'Lectura audio pro web in preparation',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
