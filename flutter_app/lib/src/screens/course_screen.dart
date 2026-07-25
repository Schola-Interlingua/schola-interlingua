import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../data/course_seed.dart';
import '../models/course_models.dart';
import '../theme/app_theme.dart';
import '../widgets/completion_panel.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CompletionTracker(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 4),
          const CompletionBanner(
            itemKey: 'course:main',
            message: 'Le curso es complete!',
          ),
          const SizedBox(height: 16),
          const _DecksEntryCard(),
          const SizedBox(height: 24),
          ...courseLevels.map(
            (CourseLevel level) => Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: _LevelSection(level: level),
            ),
          ),
          const CompletionPanel(
            itemKey: 'course:main',
            buttonLabel: 'Refacer le curso',
          ),
        ],
      ),
    );
  }
}

class _DecksEntryCard extends StatelessWidget {
  const _DecksEntryCard();

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 620;
        final Widget copy = Row(
          children: <Widget>[
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFFE54867), Color(0xFF6C8CFF)],
                ),
                borderRadius: BorderRadius.circular(19),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF6C8CFF).withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.style_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Decks de vocabulario',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${controller.favoriteWords.length} favorite · ${controller.customDecks.length} decks personal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        return ScholaCard(
          padding: EdgeInsets.all(compact ? 20 : 26),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    copy,
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      key: const Key('open-decks-button'),
                      onPressed: () => context.push('/decks'),
                      icon: const Icon(Icons.collections_bookmark_rounded),
                      label: const Text('Aperir decks'),
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    Expanded(child: copy),
                    const SizedBox(width: 24),
                    FilledButton.icon(
                      key: const Key('open-decks-button'),
                      onPressed: () => context.push('/decks'),
                      icon: const Icon(Icons.collections_bookmark_rounded),
                      label: const Text('Aperir decks'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({required this.level});

  final CourseLevel level;

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 430;

        return ScholaCard(
          padding: EdgeInsets.all(compact ? 18 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                level.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              ...level.sections.map((CourseSection section) {
                return Padding(
                  padding: EdgeInsets.only(top: compact ? 16 : 20),
                  child: Container(
                    padding: EdgeInsets.all(compact ? 14 : 18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(compact ? 20 : 24),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.10)
                            : AppTheme.borderColor(context),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          section.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppTheme.mutedTextColor(context),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: compact ? 16 : 20),
                        _CourseGrid(
                          items: section.items,
                          controller: controller,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _CourseGrid extends StatelessWidget {
  const _CourseGrid({required this.items, required this.controller});

  final List<CourseItemRef> items;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int columns = width >= 1100
            ? 5
            : width >= 900
            ? 4
            : width >= 650
            ? 3
            : 2;
        final bool compact = width < 430;
        final double childAspectRatio = width < 420
            ? 0.84
            : width < 650
            ? 0.78
            : width < 900
            ? 0.88
            : 0.96;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: compact ? 12 : 18,
            mainAxisSpacing: compact ? 12 : 18,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (BuildContext context, int index) {
            final item = items[index];
            final bool completed = controller.isCompleted(_completionKey(item));
            return _CourseGridCard(
              item: item,
              completed: completed,
              compact: compact,
              onTap: () => context.go(_pathForItem(item)),
            );
          },
        );
      },
    );
  }

  String _pathForItem(CourseItemRef item) {
    switch (item.kind) {
      case CourseItemKind.lesson:
      case CourseItemKind.vocabulary:
        return '/lesson/${item.slug}';
      case CourseItemKind.reading:
        return '/reading/${item.slug}';
      case CourseItemKind.appendix:
        return '/appendix/${item.slug}';
    }
  }

  String _completionKey(CourseItemRef item) {
    switch (item.kind) {
      case CourseItemKind.lesson:
      case CourseItemKind.vocabulary:
        return 'lesson:${item.slug}';
      case CourseItemKind.reading:
        return 'reading:${item.slug}';
      case CourseItemKind.appendix:
        return 'appendix:${item.slug}';
    }
  }
}

class _CourseGridCard extends StatelessWidget {
  const _CourseGridCard({
    required this.item,
    required this.completed,
    required this.compact,
    required this.onTap,
  });

  final CourseItemRef item;
  final bool completed;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(compact ? 18 : 22),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              dark
                  ? const Color(0xFF183A64)
                  : AppTheme.primary.withValues(alpha: 0.86),
              dark
                  ? const Color(0xFF2A5687)
                  : AppTheme.primaryLight.withValues(alpha: 0.58),
            ],
          ),
          borderRadius: BorderRadius.circular(compact ? 18 : 22),
          border: Border.all(
            color: completed
                ? const Color(0xFF8CFFB7)
                : dark
                ? const Color(0xB3D8E8FF)
                : Colors.white.withValues(alpha: 0.14),
            width: completed ? 2.4 : 1.8,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: dark ? const Color(0x66020B16) : const Color(0x260B2F58),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: dark
                  ? const Color(0x3352A8FF)
                  : Colors.white.withValues(alpha: 0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            if (completed)
              const Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(0xFF25B14B),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 10 : 14,
                compact ? 14 : 18,
                compact ? 10 : 14,
                compact ? 12 : 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: compact ? 52 : 62,
                    height: compact ? 52 : 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.10),
                      border: Border.all(
                        color: dark
                            ? Colors.white.withValues(alpha: 0.20)
                            : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Icon(
                      item.icon,
                      color: Colors.white,
                      size: compact ? 24 : 30,
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 8 : 10,
                      vertical: compact ? 8 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: dark
                            ? Colors.white.withValues(alpha: 0.14)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
