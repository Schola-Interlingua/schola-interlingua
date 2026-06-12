import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LessonAudioPlayer extends StatelessWidget {
  const LessonAudioPlayer({super.key, required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Text(
        'Audio del lection pro web in preparation.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
