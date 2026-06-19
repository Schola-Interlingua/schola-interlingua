import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../data/course_seed.dart';
import '../models/course_models.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const <Widget>[
        _ProgressCard(),
        SizedBox(height: 24),
        _AccessCard(),
      ],
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard();

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            controller.isAuthenticated ? 'Session aperte' : 'Accesso',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            controller.isAuthenticated
                ? controller.currentUser?.email ?? 'Tu session es active.'
                : 'Tu pote entrar pro synchronisar progresso o continuar como invitato.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/entrar'),
            child: Text(
              controller.isAuthenticated ? 'Gerer accesso' : 'Entrar',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final List<String> trackableKeys = _trackableCompletionKeys();
    final int totalItems = trackableKeys.length;
    final int completedItems = trackableKeys
        .where(controller.isCompleted)
        .length;
    final double progress = totalItems == 0 ? 0 : completedItems / totalItems;
    final int percent = (progress * 100).round();
    final int streak = controller.consecutiveDaysStreak;

    final String summary = completedItems == 0
        ? 'Tu non ha ancora comenciate'
        : '$completedItems de $totalItems completate ($percent%)';

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Tu progresso',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(summary, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppTheme.borderColor(context)),
              boxShadow: AppTheme.glassShadow(context),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0, 1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[AppTheme.primary, AppTheme.primaryLight],
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppTheme.primaryLight.withValues(alpha: 0.35),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              const Text('🔥', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(
                '$streak dies consecutive',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _trackableCompletionKeys() {
    return courseLevels
        .expand((CourseLevel level) => level.sections)
        .expand((CourseSection section) => section.items)
        .map((CourseItemRef item) {
          switch (item.kind) {
            case CourseItemKind.lesson:
            case CourseItemKind.vocabulary:
              return 'lesson:${item.slug}';
            case CourseItemKind.reading:
              return 'reading:${item.slug}';
            case CourseItemKind.appendix:
              return 'appendix:${item.slug}';
          }
        })
        .toList();
  }
}
