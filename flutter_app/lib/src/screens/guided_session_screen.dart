import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_state.dart';
import '../data/course_seed.dart';
import '../data/lesson_grammar_topics.dart';
import '../data/vocab_grammar_topics.dart';
import '../data/web_content_loader.dart';
import '../models/learning_practice.dart';
import '../models/web_content_models.dart';
import '../services/guided_session_store.dart';
import '../services/lesson_parts.dart';
import '../services/learning_activity_catalog.dart';
import '../services/learning_practice_store.dart';
import '../theme/app_theme.dart';
import '../widgets/learning_practice_panel.dart';
import '../widgets/lesson_audio_player.dart';
import '../widgets/lesson_grammar.dart';
import '../widgets/meaning_rich_text.dart';

class GuidedSessionScreen extends StatefulWidget {
  const GuidedSessionScreen({
    super.key,
    required this.slug,
    this.sessionStore,
    this.practiceStore,
    this.activityCatalog,
    this.playAudio,
  });
  final GuidedSessionStore? sessionStore;
  final LearningPracticeStore? practiceStore;
  final Future<LearningActivityCatalog>? activityCatalog;
  final Future<void> Function(String)? playAudio;
  final String slug;
  @override
  State<GuidedSessionScreen> createState() => _GuidedSessionScreenState();
}

class _GuidedSessionScreenState extends State<GuidedSessionScreen> {
  late final store = widget.sessionStore ?? GuidedSessionStore.instance;
  late final history = widget.practiceStore ?? LearningPracticeStore.instance;
  late Future<void> loading;
  late LearningActivityCatalog catalog;
  late List<LessonPart> parts;
  GuidedSession? session;
  ParsedLectionContent? content;
  final _top = GlobalKey();
  bool busy = false;
  String? error;
  String get title {
    for (final level in courseLevels) {
      for (final item in level.sections.expand((s) => s.items)) {
        if (item.slug == widget.slug) return item.title;
      }
    }
    return widget.slug;
  }

  List<LessonGrammarTopic> get topics =>
      lessonGrammarTopics[widget.slug] ?? vocabGrammarTopics[widget.slug] ?? [];
  @override
  void initState() {
    super.initState();
    loading = load();
  }

  @override
  void didUpdateWidget(covariant GuidedSessionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      session = null;
      content = null;
      error = null;
      loading = load();
    }
  }

  Future<void> load() async {
    final slug = widget.slug;
    await Future.wait([store.load(), history.load()]);
    final loadedCatalog =
        await (widget.activityCatalog ?? LearningActivityCatalog.load());
    final loadedContent = slug.startsWith('lection')
        ? await WebContentLoader.loadLection(slug)
        : null;
    if (!mounted || slug != widget.slug) return;
    catalog = loadedCatalog;
    content = loadedContent;
    parts = lessonParts(catalog, slug);
    final existing = store.forSource(slug);
    final ids = catalog.activities.map((a) => a.id).toSet();
    if (existing != null &&
        existing.steps.every(
          (s) =>
              s == 'intro' ||
              s == 'grammar' ||
              s == 'finish' ||
              ids.contains(s),
        )) {
      final unfinishedParts =
          store.nextPartIndex(slug, parts.length) < parts.length;
      if (((existing.partId == null &&
                  existing.index == 0 &&
                  existing.draft.isEmpty) ||
              existing.steps[existing.index] == 'finish') &&
          unfinishedParts &&
          !AppStateScope.of(context).isCompleted('lesson:$slug')) {
        await start();
      } else {
        // Keep old local sessions/drafts intact as review, without awarding a
        // fixed content part for a former random sample of exercises.
        final restored = existing.partId == null
            ? existing.copy(isReview: true)
            : existing;
        await store.save(restored);
        session = restored;
      }
    } else {
      await start();
    }
    if (!mounted || slug != widget.slug) return;
    final controller = AppStateScope.of(context);
    controller.registerVocabularySeen(slug);
    if (parts.every((part) => store.completedParts(slug).contains(part.id)) &&
        !controller.isCompleted('lesson:$slug')) {
      controller.markCompleted('lesson:$slug');
    }
  }

  Future<void> start({int? partIndex, bool forceRestart = false}) async {
    final legacyComplete = AppStateScope.of(
      context,
    ).isCompleted('lesson:${widget.slug}');
    final pending = store.nextPartIndex(widget.slug, parts.length);
    final index =
        partIndex ?? (legacyComplete || pending >= parts.length ? 0 : pending);
    final part = parts[index];
    final previous = store.forPart(widget.slug, part.id);
    if (!forceRestart &&
        previous != null &&
        previous.steps[previous.index] != 'finish') {
      await store.save(previous);
      session = previous;
      return;
    }
    final prior = catalog.activities
        .where((a) {
          if (a.sourceSlug == widget.slug) return false;
          final due = practiceDueAt(history.events, a.id);
          return due != null && !due.isAfter(DateTime.now());
        })
        .take(1)
        .toList();
    final next = GuidedSession(
      slug: widget.slug,
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      partId: part.id,
      partIndex: part.index,
      partCount: parts.length,
      isReview:
          legacyComplete || store.completedParts(widget.slug).contains(part.id),
      steps: [
        'intro',
        if (part.grammarIndex != null) 'grammar',
        ...part.activities.map((a) => a.id),
        ...prior.map((a) => a.id),
        'finish',
      ],
    );
    await store.save(next);
    session = next;
  }

  List<LessonGrammarTopic> get activeTopics {
    if (session?.partId == null) return topics.isEmpty ? [] : [topics.first];
    final index =
        parts[session!.partIndex.clamp(0, parts.length - 1)].grammarIndex;
    return index == null ? [] : [topics[index]];
  }

  Future<void> advance({bool needsReview = false}) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final old = session!;
      final next = old.advance(needsReview: needsReview);
      await store.save(next);
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => session = next);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _top.currentContext;
        if (mounted && target != null) {
          Scrollable.ensureVisible(target, alignment: 0);
        }
      });
      if (next.steps[next.index] == 'finish' &&
          parts.every(
            (part) => store.completedParts(widget.slug).contains(part.id),
          ) &&
          !AppStateScope.of(context).isCompleted('lesson:${widget.slug}')) {
        AppStateScope.of(context).markCompleted('lesson:${widget.slug}');
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Non pote salvar le session. Essaya de novo.');
      }
      rethrow;
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void draft(String value) {
    final next = session!.copy(draft: value);
    session = next;
    store.save(next).catchError((Object _) {
      if (mounted) {
        setState(() => error = 'Non pote salvar le responsa. Essaya de novo.');
      }
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: loading,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return ScholaCard(
          child: Column(
            children: [
              const Text('Non pote cargar le session.'),
              TextButton(
                onPressed: () => setState(() => loading = load()),
                child: const Text('Reprobar'),
              ),
              TextButton(
                onPressed: () => context.go('/course'),
                child: const Text('Retornar al curso'),
              ),
            ],
          ),
        );
      }
      if (snapshot.connectionState != ConnectionState.done || session == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final state = session!;
      final step = state.steps[state.index];
      final activity = catalog.activities
          .where((a) => a.id == step)
          .firstOrNull;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: Column(
            key: _top,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: busy ? null : showParts,
                    child: const Text('Partes'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/course'),
                    child: const Text('Pausa'),
                  ),
                ],
              ),
              Text(
                state.partId == null
                    ? 'Session de repaso'
                    : 'Parte ${state.partIndex + 1} de ${parts.length}',
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: step == 'finish'
                    ? 1
                    : state.index / (state.steps.length - 1),
              ),
              const SizedBox(height: 8),
              Text(
                step == 'finish'
                    ? 'Session complete'
                    : 'Activitate ${state.index + 1} / ${state.steps.length - 1}',
              ),
              const SizedBox(height: 16),
              if (step == 'intro')
                _intro()
              else if (step == 'grammar')
                LessonGrammar(
                  slug: widget.slug,
                  topics: activeTopics.isEmpty ? null : activeTopics,
                  bullets: content?.grammarBullets ?? [],
                )
              else if (step == 'finish')
                _finish()
              else if (activity != null) ...[
                if (state.repeated.contains(step) ||
                    activity.sourceSlug != widget.slug)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Un breve repaso pro consolidar lo que tu practicava.',
                    ),
                  ),
                LearningPracticePanel(
                  key: ValueKey(state.runId),
                  slug: activity.sourceSlug,
                  activity: activity,
                  store: history,
                  playAudio: widget.playAudio,
                  runId: state.runId,
                  initialInput: state.draft,
                  catalog: Future.value(catalog),
                  onInputChanged: draft,
                  onAdvance: (needsReview) => advance(needsReview: needsReview),
                ),
              ],
              if (step == 'intro' || step == 'grammar')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: FilledButton(
                    onPressed: busy
                        ? null
                        : () async {
                            try {
                              await advance();
                            } catch (_) {}
                          },
                    child: const Text('Continuar'),
                  ),
                ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/lesson/${widget.slug}'),
                child: const Text('Consultar le material complete'),
              ),
            ],
          ),
        ),
      );
    },
  );
  Widget _intro() {
    final controller = AppStateScope.of(context);
    final firstContext =
        content != null && (session!.partId == null || session!.partIndex == 0);
    final words = <String>{
      if (session!.partId != null) ...parts[session!.partIndex].terms,
    };
    for (final id in session!.steps) {
      final activity = catalog.activities.where((a) => a.id == id).firstOrNull;
      if (activity != null &&
          activity.sourceSlug == widget.slug &&
          activity.mode == PracticeMode.dictation) {
        words.add(activity.answers.first);
      }
    }
    final items = controller.lessonItems(widget.slug);
    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            firstContext ? 'Ascolta e lege' : 'Explora le parolas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (firstContext && content?.audioAsset != null) ...[
            const SizedBox(height: 16),
            LessonAudioPlayer(
              key: ValueKey(content!.audioAsset),
              assetPath: content!.audioAsset!,
            ),
          ],
          const SizedBox(height: 16),
          if (firstContext)
            for (final paragraph in content!.paragraphs)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MeaningRichText(text: paragraph),
              )
          else
            for (final item in items.where((i) => words.contains(i['term'])))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${item['term']} · ${item[controller.selectedLanguage] ?? item['es'] ?? ''}',
                ),
              ),
        ],
      ),
    );
  }

  Future<void> openPart(int index, {bool restart = false}) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await start(partIndex: index, forceRestart: restart);
      if (mounted) {
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final target = _top.currentContext;
          if (mounted && target != null) Scrollable.ensureVisible(target);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Non pote cargar le parte. Essaya de novo.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> showParts() async {
    final completed = store.completedParts(widget.slug);
    final legacyComplete = AppStateScope.of(
      context,
    ).isCompleted('lesson:${widget.slug}');
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          for (final part in parts)
            SimpleDialogOption(
              key: ValueKey('choose-${part.id}'),
              onPressed: () => Navigator.pop(context, part.index),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  legacyComplete || completed.contains(part.id)
                      ? Icons.check_circle_rounded
                      : Icons.play_circle_outline_rounded,
                ),
                title: Text('Parte ${part.index + 1}'),
                subtitle: Text(
                  [
                    if (part.grammarIndex != null)
                      topics[part.grammarIndex!].title,
                    ...part.terms.take(3),
                  ].join(' · '),
                ),
              ),
            ),
        ],
      ),
    );
    if (selected != null && mounted) await openPart(selected);
  }

  Widget _finish() {
    final pending = store.nextPartIndex(widget.slug, parts.length);
    final allDone =
        pending >= parts.length ||
        AppStateScope.of(context).isCompleted('lesson:${widget.slug}');
    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle_rounded, size: 44),
          const SizedBox(height: 12),
          Text('Ben facite!', style: Theme.of(context).textTheme.headlineSmall),
          Text(
            session!.partId == null
                ? 'Tu ha finite le repaso.'
                : 'Parte ${session!.partIndex + 1} de ${parts.length} complete.',
          ),
          const SizedBox(height: 8),
          Text(
            allDone
                ? 'Tu ha completate tote le partes de iste thema.'
                : 'Le aro del thema monstra tu progresso. Tu pote continuar o retornar al curso.',
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('continue-next-part'),
            onPressed: busy
                ? null
                : () {
                    if (allDone) {
                      context.go('/course');
                    } else {
                      openPart(pending);
                    }
                  },
            child: Text(
              allDone
                  ? 'Continuar le curso'
                  : 'Continuar · Parte ${pending + 1}',
            ),
          ),
          if (!allDone)
            TextButton(
              onPressed: () => context.go('/course'),
              child: const Text('Retornar al curso'),
            ),
          TextButton(
            onPressed: busy
                ? null
                : () => openPart(session!.partIndex, restart: true),
            child: const Text('Repetir iste parte'),
          ),
        ],
      ),
    );
  }
}
