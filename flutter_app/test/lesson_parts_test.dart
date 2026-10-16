import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schola_interlingua_flutter/src/app_state.dart';
import 'package:schola_interlingua_flutter/src/data/course_seed.dart';
import 'package:schola_interlingua_flutter/src/data/lesson_grammar_topics.dart';
import 'package:schola_interlingua_flutter/src/data/vocab_grammar_topics.dart';
import 'package:schola_interlingua_flutter/src/models/course_models.dart';
import 'package:schola_interlingua_flutter/src/models/learning_practice.dart';
import 'package:schola_interlingua_flutter/src/screens/guided_session_screen.dart';
import 'package:schola_interlingua_flutter/src/services/guided_session_store.dart';
import 'package:schola_interlingua_flutter/src/services/learning_activity_catalog.dart';
import 'package:schola_interlingua_flutter/src/services/learning_practice_store.dart';
import 'package:schola_interlingua_flutter/src/services/lesson_parts.dart';
import 'package:schola_interlingua_flutter/src/theme/app_theme.dart';
import 'package:schola_interlingua_flutter/src/widgets/topic_progress_ring.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'fixed parts cover every exercise, vocabulary term and grammar topic exactly once',
    () async {
      final catalog = await LearningActivityCatalog.load();
      for (final item
          in courseLevels
              .expand((l) => l.sections)
              .expand((s) => s.items)
              .where(
                (i) =>
                    i.kind == CourseItemKind.lesson ||
                    i.kind == CourseItemKind.vocabulary,
              )) {
        final parts = lessonParts(catalog, item.slug);
        final ids = parts.expand((p) => p.activities).map((a) => a.id).toList();
        final all = catalog.activities
            .where((a) => a.sourceSlug == item.slug)
            .map((a) => a.id)
            .toList();
        expect(ids.toSet(), all.toSet(), reason: item.slug);
        expect(ids.length, ids.toSet().length);
        expect(parts.every((p) => p.activities.length <= 4), isTrue);
        expect(
          parts.expand((p) => p.terms).toSet(),
          catalog.termsBySource[item.slug]!.toSet(),
        );
        final topics =
            lessonGrammarTopics[item.slug] ??
            vocabGrammarTopics[item.slug] ??
            [];
        expect(
          parts.map((p) => p.grammarIndex).whereType<int>().toList(),
          List.generate(topics.length, (i) => i),
        );
        expect(parts.map((p) => p.id).toSet().length, parts.length);
      }
    },
  );
  test(
    'finishing and replaying a part is idempotent and preserves another part draft',
    () async {
      final store = GuidedSessionStore();
      const first = GuidedSession(
        slug: 'test',
        id: 'one',
        steps: ['intro', 'finish'],
        index: 1,
        partId: 'test-part-1',
        partIndex: 0,
        partCount: 2,
      );
      const second = GuidedSession(
        slug: 'test',
        id: 'two',
        steps: ['intro', 'activity', 'finish'],
        index: 1,
        draft: 'unfinished',
        partId: 'test-part-2',
        partIndex: 1,
        partCount: 2,
      );
      await store.save(first);
      await store.save(first);
      await store.save(second);
      await store.save(first.copy(isReview: true));
      final restored = GuidedSessionStore();
      await restored.load();
      expect(restored.completedParts('test'), {'test-part-1'});
      expect(restored.nextPartIndex('test', 2), 1);
      expect(restored.forPart('test', 'test-part-2')!.draft, 'unfinished');
      await restored.save(second.advance());
      expect(restored.nextPartIndex('test', 2), 2);
      expect(restored.completedParts('test').length, 2);
    },
  );
  testWidgets(
    'one topic finishes only after all parts; revisiting a finished part preserves the pending draft',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = AppController();
      await tester.runAsync(controller.loadVocab);
      final store = GuidedSessionStore();
      final history = LearningPracticeStore();
      final catalog = LearningActivityCatalog([
        for (var i = 0; i < 5; i++)
          LearningActivity(
            id: 'a$i',
            sourceSlug: 'basico1',
            mode: PracticeMode.cloze,
            prompt: 'Le puera ____ belle.',
            answers: ['es'],
            explanation: 'Esser.',
          ),
      ]);
      await tester.pumpWidget(
        AppStateScope(
          controller: controller,
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: GuidedSessionScreen(
                  slug: 'basico1',
                  sessionStore: store,
                  practiceStore: history,
                  activityCatalog: Future.value(catalog),
                ),
              ),
            ),
          ),
        ),
      );
      Future<void> settle() async {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pumpAndSettle();
      }

      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f);
        await tester.tap(f);
        await settle();
      }

      Future<void> solve() async {
        await tester.enterText(find.byKey(const Key('practice-answer')), 'es');
        await tap(find.byKey(const Key('practice-check')));
        await tap(find.byKey(const Key('practice-next')));
      }

      await settle();
      expect(find.text('Parte 1 de 2'), findsOneWidget);
      await tap(find.text('Continuar'));
      await tap(find.text('Continuar'));
      for (var i = 0; i < 4; i++) {
        await solve();
      }
      expect(find.text('Ben facite!'), findsOneWidget);
      expect(controller.isCompleted('lesson:basico1'), isFalse);
      expect(store.completedParts('basico1').length, 1);
      await tap(find.byKey(const Key('continue-next-part')));
      expect(find.text('Parte 2 de 2'), findsOneWidget);
      await tap(find.text('Continuar'));
      await tester.enterText(find.byKey(const Key('practice-answer')), 'draft');
      await settle();
      await tap(find.text('Partes'));
      await tap(find.byKey(const Key('choose-basico1-part-1')));
      expect(find.text('Parte 1 de 2'), findsOneWidget);
      expect(store.current!.isReview, isTrue);
      await tap(find.text('Partes'));
      await tap(find.byKey(const Key('choose-basico1-part-2')));
      expect(find.text('draft'), findsOneWidget);
      await solve();
      expect(controller.isCompleted('lesson:basico1'), isTrue);
      expect(store.completedParts('basico1').length, 2);
      expect(
        find.text('Tu ha completate tote le partes de iste thema.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'segmented ring remains compact and repaints when progress changes',
    (tester) async {
      for (final count in [0, 1, 3]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox(
                width: 62,
                height: 62,
                child: TopicProgressRing(
                  parts: 3,
                  completed: count,
                  child: const Icon(Icons.school),
                ),
              ),
            ),
          ),
        );
        expect(
          tester.getSize(find.byType(TopicProgressRing)),
          const Size(62, 62),
        );
        expect(tester.takeException(), isNull);
      }
    },
  );
}
