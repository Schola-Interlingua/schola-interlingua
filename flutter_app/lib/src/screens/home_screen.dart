import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../data/course_seed.dart';
import '../models/course_models.dart';
import '../models/srs_models.dart';
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
        _SrsOverviewCard(),
        SizedBox(height: 24),
        _QuickReviewCard(),
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

class _SrsOverviewCard extends StatelessWidget {
  const _SrsOverviewCard();

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final Map<SrsStage, int> counts = controller.srsStageCounts;
    final int total = controller.trackedSrsWordCount;
    final int due = controller.dueSrsWordCount;
    const Map<SrsStage, Color> colors = <SrsStage, Color>{
      SrsStage.newWord: Color(0xFF7C8AA5),
      SrsStage.learning: Color(0xFF3BA4FF),
      SrsStage.reviewing: Color(0xFF20C997),
      SrsStage.mastered: Color(0xFFF5B942),
    };
    const Map<SrsStage, String> labels = <SrsStage, String>{
      SrsStage.newWord: 'Nove',
      SrsStage.learning: 'In studio',
      SrsStage.reviewing: 'In revision',
      SrsStage.mastered: 'Apprendite',
    };

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Parolas e repetition',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            total == 0
                ? 'Nulle parola ha entrate ancora in le repetition integrate.'
                : '$total parolas in le systema. $due debite ora.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Container(
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppTheme.borderColor(context)),
            ),
            child: total == 0
                ? const SizedBox.expand()
                : Row(
                    children: SrsStage.values.map((SrsStage stage) {
                      final int count = counts[stage] ?? 0;
                      if (count == 0) {
                        return const SizedBox.shrink();
                      }
                      return Expanded(
                        flex: count,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors[stage],
                            borderRadius: BorderRadius.only(
                              topLeft: stage == SrsStage.values.first
                                  ? const Radius.circular(999)
                                  : Radius.zero,
                              bottomLeft: stage == SrsStage.values.first
                                  ? const Radius.circular(999)
                                  : Radius.zero,
                              topRight: stage == SrsStage.values.last
                                  ? const Radius.circular(999)
                                  : Radius.zero,
                              bottomRight: stage == SrsStage.values.last
                                  ? const Radius.circular(999)
                                  : Radius.zero,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: SrsStage.values.map((SrsStage stage) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[stage],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${labels[stage]}: ${counts[stage] ?? 0}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickReviewCard extends StatelessWidget {
  const _QuickReviewCard();

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final int due = controller.dueSrsWordCount;

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Repaso rapide',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            due == 0
                ? 'Tu non ha cartas debite ora. Quando tu vide vocabulario del curso, illos appare hic automaticamente.'
                : 'Tu ha $due cartas preste pro un quiz rapide.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: due == 0 ? null : () => context.go('/review'),
            icon: const Icon(Icons.bolt_rounded),
            label: Text(due == 0 ? 'Nulle repaso ora' : 'Repasar ora'),
          ),
        ],
      ),
    );
  }
}
