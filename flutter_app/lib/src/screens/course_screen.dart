import '../services/learning_activity_catalog.dart';
import '../services/lesson_parts.dart';
import '../services/guided_session_store.dart';
import '../widgets/topic_progress_ring.dart';
import '../widgets/continue_learning.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../data/course_seed.dart';
import '../models/course_models.dart';
import '../theme/app_theme.dart';
import '../widgets/completion_panel.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  Future<LearningActivityCatalog> load() async {
    await GuidedSessionStore.instance.load();
    return LearningActivityCatalog.load();
  }

  late Future<LearningActivityCatalog> loading = load();
  @override
  Widget build(BuildContext context) => FutureBuilder<LearningActivityCatalog>(
    future: loading,
    builder: (context, snapshot) => ListenableBuilder(
      listenable: GuidedSessionStore.instance,
      builder: (context, _) => _body(context, snapshot.data, snapshot.hasError),
    ),
  );
  Widget _body(
    BuildContext context,
    LearningActivityCatalog? catalog,
    bool failed,
  ) {
    return CompletionTracker(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CompletionBanner(
                itemKey: 'course:main',
                message: 'Le curso es complete!',
              ),
              const ContinueLearning(),
              if (failed)
                TextButton(
                  onPressed: () => setState(() => loading = load()),
                  child: const Text('Recargar le partes'),
                ),
              const _DecksEntry(),
              const SizedBox(height: 18),
              for (final level in courseLevels)
                _LevelPath(level: level, catalog: catalog),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecksEntry extends StatelessWidget {
  const _DecksEntry();
  @override
  Widget build(BuildContext context) => TextButton(
    key: const Key('open-decks-button'),
    onPressed: () => context.push('/decks'),
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      foregroundColor: AppTheme.textColor(context),
      backgroundColor: AppTheme.surfaceVariant(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    child: const Row(
      children: [
        Icon(Icons.collections_bookmark_rounded, size: 22),
        SizedBox(width: 12),
        Expanded(child: Text('Decks de vocabulario')),
        Icon(Icons.chevron_right_rounded, size: 20),
      ],
    ),
  );
}

class _LevelPath extends StatelessWidget {
  const _LevelPath({required this.level, this.catalog});
  final LearningActivityCatalog? catalog;
  final CourseLevel level;

  @override
  Widget build(BuildContext context) {
    final controller = AppStateScope.of(context);
    final items = level.sections.expand((section) => section.items).toList();
    final nextIndex = items.indexWhere(
      (item) => !controller.isCompleted(_completionKey(item)),
    );
    final sections = <({CourseSection section, int offset})>[];
    var offset = 0;
    for (final section in level.sections) {
      sections.add((section: section, offset: offset));
      offset += section.items.length;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showLevelSummary(context, level),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                key: ValueKey('course-level-${level.slug}'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF12385B), offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        level.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in sections) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Expanded(child: Divider(color: AppTheme.borderColor(context))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    entry.section.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.mutedTextColor(context),
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppTheme.borderColor(context))),
              ],
            ),
          ),
          _TopicPath(
            items: entry.section.items,
            startIndex: entry.offset,
            nextIndex: nextIndex,
            controller: controller,
            catalog: catalog,
          ),
        ],
        const SizedBox(height: 28),
      ],
    );
  }
}

const _wave = <double>[0, .65, 1, .65, 0, -.65, -1, -.65];

class _TopicPath extends StatelessWidget {
  const _TopicPath({
    required this.items,
    required this.startIndex,
    required this.nextIndex,
    required this.controller,
    this.catalog,
  });
  final List<CourseItemRef> items;
  final int startIndex, nextIndex;
  final AppController controller;
  final LearningActivityCatalog? catalog;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final amplitude = math.min(
        88.0,
        math.max(0.0, constraints.maxWidth / 2 - 76),
      );
      final textScale = MediaQuery.textScalerOf(context).scale(13) / 13;
      final step = 116.0 + math.max(0.0, textScale - 1) * 60;
      final centers = [
        for (var index = 0; index < items.length; index++)
          Offset(
            constraints.maxWidth / 2 +
                _wave[(startIndex + index) % _wave.length] * amplitude,
            index * step + 32,
          ),
      ];
      return Column(
        children: [
          for (var index = 0; index < items.length; index++)
            SizedBox(
              height: step,
              child: Align(
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: Offset(
                    centers[index].dx - constraints.maxWidth / 2,
                    0,
                  ),
                  child: _TopicNode(
                    item: items[index],
                    totalParts: catalog == null
                        ? 1
                        : lessonParts(catalog!, items[index].slug).length,
                    completedParts: GuidedSessionStore.instance
                        .completedParts(items[index].slug)
                        .length,
                    completed: controller.isCompleted(
                      _completionKey(items[index]),
                    ),
                    next: startIndex + index == nextIndex,
                    height: step,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _TopicNode extends StatelessWidget {
  const _TopicNode({
    required this.item,
    required this.completed,
    required this.next,
    required this.height,
    required this.totalParts,
    required this.completedParts,
  });
  final CourseItemRef item;
  final bool completed, next;
  final double height;
  final int totalParts, completedParts;
  bool get hasParts =>
      item.kind == CourseItemKind.lesson ||
      item.kind == CourseItemKind.vocabulary;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = completed
        ? const Color(0xFF23794F)
        : next
        ? const Color(0xFF327BB7)
        : dark
        ? const Color(0xFF234B70)
        : const Color(0xFF2C6292);
    return Semantics(
      key: ValueKey('course-node-${item.kind.name}-${item.slug}'),
      button: true,
      label: completed
          ? '${item.title}, complete'
          : hasParts && totalParts > 1
          ? '${item.title}, $completedParts de $totalParts partes completate'
          : item.title,
      child: Tooltip(
        message: item.title,
        excludeFromSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => context.go(_pathForItem(item)),
            borderRadius: BorderRadius.circular(16),
            child: ExcludeSemantics(
              child: SizedBox(
                width: 148,
                height: height,
                child: Column(
                  children: [
                    SizedBox(
                      key: ValueKey(
                        'course-circle-${item.kind.name}-${item.slug}',
                      ),
                      width: 62,
                      height: 62,
                      child: TopicProgressRing(
                        key: ValueKey('course-ring-${item.slug}'),
                        parts: hasParts ? totalParts : 1,
                        completed: completed
                            ? (hasParts ? totalParts : 1)
                            : completedParts.clamp(0, totalParts),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: fill,
                            boxShadow: [
                              BoxShadow(
                                color: completed
                                    ? const Color(0xFF154B32)
                                    : const Color(0xFF163952),
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            completed ? Icons.check_rounded : item.icon,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: hasParts && totalParts > 1 ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: 13,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    if (hasParts && totalParts > 1)
                      Text(
                        '${completed ? totalParts : completedParts.clamp(0, totalParts)}/$totalParts',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.mutedTextColor(context),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _pathForItem(CourseItemRef item) => switch (item.kind) {
  CourseItemKind.lesson || CourseItemKind.vocabulary => '/session/${item.slug}',
  CourseItemKind.reading => '/reading/${item.slug}',
  CourseItemKind.appendix => '/appendix/${item.slug}',
};

String _completionKey(CourseItemRef item) => switch (item.kind) {
  CourseItemKind.lesson || CourseItemKind.vocabulary => 'lesson:${item.slug}',
  CourseItemKind.reading => 'reading:${item.slug}',
  CourseItemKind.appendix => 'appendix:${item.slug}',
};

Future<void> _showLevelSummary(BuildContext context, CourseLevel level) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(level.title),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Que apprendera tu?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              for (final goal in level.learningGoals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Icon(Icons.check_rounded, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(goal)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Continuar'),
        ),
      ],
    ),
  );
}
