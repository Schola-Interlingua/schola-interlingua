import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../data/course_seed.dart';
import '../models/course_models.dart';
import '../services/guided_session_store.dart';

class ContinueLearning extends StatefulWidget {
  const ContinueLearning({super.key, this.store});
  final GuidedSessionStore? store;
  @override
  State<ContinueLearning> createState() => _ContinueLearningState();
}

class _ContinueLearningState extends State<ContinueLearning> {
  late final store = widget.store ?? GuidedSessionStore.instance;
  late final Future<void> loading = store.load();
  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: loading,
    builder: (context, snapshot) => ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final controller = AppStateScope.of(context);
        final lessons = courseLevels
            .expand((l) => l.sections)
            .expand((s) => s.items)
            .where(
              (i) =>
                  i.kind == CourseItemKind.lesson ||
                  i.kind == CourseItemKind.vocabulary,
            )
            .toList();
        final current = store.current;
        final inProgress =
            current != null && current.steps[current.index] != 'finish';
        final hasNextPart =
            current != null &&
            current.partId != null &&
            !controller.isCompleted('lesson:${current.slug}') &&
            store.nextPartIndex(current.slug, current.partCount) <
                current.partCount;
        final resumable = inProgress || hasNextPart;
        final partIndex = current == null
            ? 0
            : inProgress
            ? current.partIndex
            : store.nextPartIndex(current.slug, current.partCount);
        final slug = resumable
            ? current.slug
            : lessons
                  .firstWhere(
                    (i) => !controller.isCompleted('lesson:${i.slug}'),
                    orElse: () => lessons.first,
                  )
                  .slug;
        final title = lessons
            .firstWhere((i) => i.slug == slug, orElse: () => lessons.first)
            .title;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FilledButton.icon(
            key: const Key('continue-learning'),
            onPressed: snapshot.connectionState != ConnectionState.done
                ? null
                : () => context.go('/session/$slug'),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                resumable
                    ? current.partId != null
                          ? 'Continuar · $title · Parte ${partIndex + 1}/${current.partCount}'
                          : 'Continuar · $title · ${current.index + 1}/${current.steps.length - 1}'
                    : 'Continuar · $title',
              ),
            ),
          ),
        );
      },
    ),
  );
}
