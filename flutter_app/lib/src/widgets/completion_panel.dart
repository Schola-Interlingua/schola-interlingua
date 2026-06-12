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
    if (completedAt == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FilledButton(
          onPressed: () => controller.markCompleted(itemKey),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(buttonLabel),
        ),
        const SizedBox(height: 8),
        Text(
          'Ultime vice: ${_formatDate(completedAt)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.mutedTextColor(context),
          ),
        ),
      ],
    );
  }

  static String _formatDate(String isoDate) {
    final DateTime parsed = DateTime.tryParse(isoDate)?.toLocal() ?? DateTime.now();
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
      color: const Color(0xFFDFF4E2),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF156C2F),
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class CompletionTracker extends StatefulWidget {
  const CompletionTracker({
    super.key,
    required this.itemKey,
    required this.child,
  });

  final String itemKey;
  final Widget child;

  @override
  State<CompletionTracker> createState() => _CompletionTrackerState();
}

class _CompletionTrackerState extends State<CompletionTracker> {
  bool _marked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_marked) return;
    _marked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppStateScope.of(context).markCompleted(widget.itemKey);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
