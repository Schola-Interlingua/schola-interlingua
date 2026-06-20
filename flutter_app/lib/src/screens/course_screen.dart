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

class _LevelSection extends StatelessWidget {
  const _LevelSection({required this.level});

  final CourseLevel level;

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    return ScholaCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(level.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          ...level.sections.map((CourseSection section) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(24),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.mutedTextColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _CourseGrid(items: section.items, controller: controller),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CourseGrid extends StatelessWidget {
  const _CourseGrid({required this.items, required this.controller});

  final List<CourseItemRef> items;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final int columns = width >= 1100
        ? 5
        : width >= 900
        ? 4
        : width >= 650
        ? 3
        : 2;
    final double childAspectRatio = width < 420
        ? 0.72
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
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];
        final bool completed = controller.isCompleted(_completionKey(item));
        return _CourseGridCard(
          item: item,
          completed: completed,
          onTap: () => context.go(_pathForItem(item)),
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
    required this.onTap,
  });

  final CourseItemRef item;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
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
          borderRadius: BorderRadius.circular(22),
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
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 62,
                    height: 62,
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
                    child: Icon(item.icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
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
                        fontSize: 16,
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
