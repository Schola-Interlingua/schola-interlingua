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
      itemKey: 'course:main',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    section.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(
                      color: AppTheme.mutedTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _CourseGrid(items: section.items, controller: controller),
                ],
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];
        final bool completed = controller.isCompleted(_completionKey(item));
        return InkWell(
          onTap: () => context.go(_pathForItem(item)),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppTheme.primary, AppTheme.primaryLight],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: completed ? const Color(0xFF3AE374) : AppTheme.borderColor(context),
                width: completed ? 2 : 1,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.08),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: completed
                        ? const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFF25B14B),
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          )
                        : const SizedBox(height: 32),
                  ),
                  const Spacer(),
                  Icon(item.icon, color: Colors.white, size: 34),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
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
