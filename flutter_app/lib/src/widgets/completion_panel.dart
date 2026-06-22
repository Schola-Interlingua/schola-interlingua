import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';

class CompletionPanel extends StatelessWidget {
  const CompletionPanel({
    super.key,
    required this.itemKey,
    required this.buttonLabel,
  });

  final String itemKey;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final String? completedAt = controller.completionDate(itemKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FilledButton(
          onPressed: () {
            if (completedAt == null) {
              controller.markCompleted(itemKey);
              return;
            }
            controller.clearCompleted(itemKey);
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.14)
                : AppTheme.primary.withValues(alpha: 0.92),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: Text(
            completedAt == null ? 'Marcar como complete' : buttonLabel,
          ),
        ),
        if (completedAt != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            'Ultime vice: ${_formatDate(completedAt)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mutedTextColor(context),
            ),
          ),
        ],
      ],
    );
  }

  static String _formatDate(String isoDate) {
    final DateTime parsed =
        DateTime.tryParse(isoDate)?.toLocal() ?? DateTime.now();
    final String month = parsed.month.toString().padLeft(2, '0');
    final String day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }
}

class CompletionBanner extends StatelessWidget {
  const CompletionBanner({
    super.key,
    required this.itemKey,
    required this.message,
  });

  final String itemKey;
  final String message;

  @override
  Widget build(BuildContext context) {
    if (!AppStateScope.of(context).isCompleted(itemKey)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.successBannerBackground(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.successBannerBorder(context)),
        boxShadow: AppTheme.glassShadow(context),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.successBannerText(context),
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class CompletionTracker extends StatefulWidget {
  const CompletionTracker({super.key, required this.child});

  final Widget child;

  @override
  State<CompletionTracker> createState() => _CompletionTrackerState();
}

class _CompletionTrackerState extends State<CompletionTracker> {
  @override
  Widget build(BuildContext context) => widget.child;
}
