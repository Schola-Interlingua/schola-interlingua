import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:schola_interlingua_flutter/src/widgets/continue_learning.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schola_interlingua_flutter/src/app_state.dart';
import 'package:schola_interlingua_flutter/src/models/learning_practice.dart';
import 'package:schola_interlingua_flutter/src/services/guided_session_store.dart';
import 'package:schola_interlingua_flutter/src/services/learning_activity_catalog.dart';
import 'package:schola_interlingua_flutter/src/services/learning_practice_store.dart';
import 'package:schola_interlingua_flutter/src/screens/guided_session_screen.dart';
import 'package:schola_interlingua_flutter/src/theme/app_theme.dart';
import 'package:schola_interlingua_flutter/src/widgets/learning_practice_panel.dart';

LearningActivity activity(
  String id, {
  PracticeMode mode = PracticeMode.cloze,
}) => LearningActivity(
  id: id,
  sourceSlug: 'basico1',
  mode: mode,
  prompt: mode == PracticeMode.cloze
      ? 'Le puera ____ belle.'
      : 'Ascolta e scribe in Interlingua.',
  answers: [mode == PracticeMode.cloze ? 'es' : 'puera'],
  explanation: 'Le verbo es es.',
  audioAsset: mode == PracticeMode.dictation ? 'test.wav' : null,
);
PracticeEvent event(
  String id,
  DateTime at, {
  bool correct = false,
  List<String> support = const [],
  int attempt = 1,
}) => PracticeEvent(
  id: '$id-${at.microsecondsSinceEpoch}',
  runId: 'old',
  activityId: id,
  sourceSlug: 'basico1',
  mode: PracticeMode.cloze,
  kind: PracticeEventKind.answer,
  at: at,
  support: support,
  plays: 0,
  attemptNumber: attempt,
  elapsedMs: 1,
  correct: correct,
  answer: correct ? 'es' : 'error',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => SharedPreferences.setMockInitialValues({'keep_srs': 'untouched'}),
  );
  test(
    'due errors precede unseen content; independent recall schedules future review',
    () {
      final now = DateTime(2026, 10, 16);
      final history = [
        event('mistake', now),
        event('helped', now, correct: true, support: ['first-letter']),
        event('clean', now, correct: true),
        event('due', now.subtract(const Duration(days: 2)), correct: true),
      ];
      expect(practiceDueAt(history, 'mistake'), now);
      expect(practiceDueAt(history, 'helped'), now);
      expect(practiceDueAt(history, 'clean'), now.add(const Duration(days: 1)));
      final selected = selectSessionActivities(
        ['clean', 'new', 'mistake', 'helped', 'due'].map(activity).toList(),
        history,
        now,
      );
      expect(selected.map((a) => a.id), ['due', 'mistake', 'helped', 'new']);
      expect(
        practiceDueAt([
          ...history,
          event('mistake', now.add(const Duration(minutes: 1)), correct: true),
        ], 'mistake'),
        now.add(const Duration(days: 1, minutes: 1)),
      );
    },
  );
  test(
    'retry is delayed behind other exercises, added once and survives reload with drafts',
    () async {
      const initial = GuidedSession(
        slug: 'basico1',
        id: 'run',
        steps: ['intro', 'a', 'b', 'c', 'finish'],
        index: 1,
        draft: 'draft',
      );
      final next = initial.advance(needsReview: true);
      expect(next.steps, ['intro', 'a', 'b', 'c', 'a', 'finish']);
      expect(next.index, 2);
      expect(next.draft, '');
      final retry = next.copy(index: 4).advance(needsReview: true);
      expect(retry.steps, next.steps);
      final store = GuidedSessionStore();
      await Future.wait([
        store.save(next.copy(draft: 'unfinished')),
        store.save(
          const GuidedSession(
            slug: 'lection1',
            id: 'other',
            steps: ['intro', 'finish'],
          ),
        ),
      ]);
      final restored = GuidedSessionStore();
      await restored.load();
      expect(restored.current!.slug, 'lection1');
      expect(restored.forSource('basico1')!.draft, 'unfinished');
      expect(restored.forSource('basico1')!.steps, next.steps);
      expect(
        (await SharedPreferences.getInstance()).getString('keep_srs'),
        'untouched',
      );
    },
  );
  testWidgets(
    'Continue resumes saved work and then suggests the next unfinished lesson',
    (tester) async {
      final controller = AppController();
      final store = GuidedSessionStore();
      await tester.runAsync(
        () => store.save(
          const GuidedSession(
            slug: 'basico1',
            id: 'saved',
            steps: ['intro', 'a', 'finish'],
            index: 1,
            draft: 'pu',
          ),
        ),
      );
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                Scaffold(body: ContinueLearning(store: store)),
          ),
          GoRoute(
            path: '/session/:slug',
            builder: (context, state) => Text(state.pathParameters['slug']!),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        AppStateScope(
          controller: controller,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Continuar · Basico1 · 2/2'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('continue-learning')))
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.byKey(const Key('continue-learning')));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        '/session/basico1',
      );
      await tester.runAsync(() => store.save(store.current!.copy(index: 2)));
      controller.markCompleted('lesson:lection1');
      router.go('/');
      await tester.pumpAndSettle();
      expect(find.text('Continuar · Lection 2'), findsOneWidget);
      expect(store.forSource('basico1')!.draft, 'pu');
    },
  );

  testWidgets(
    'guided session saves a wrong answer, resumes, alternates audio and delays retry before completion',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = AppController();
      await tester.runAsync(controller.loadVocab);
      var store = GuidedSessionStore();
      final history = LearningPracticeStore();
      final catalog = Future.value(
        LearningActivityCatalog([
          activity('a'),
          activity('b'),
          activity('d', mode: PracticeMode.dictation),
        ]),
      );
      var plays = 0;
      Widget app() => AppStateScope(
        controller: controller,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: GuidedSessionScreen(
                slug: 'basico1',
                sessionStore: store,
                practiceStore: history,
                activityCatalog: catalog,
                playAudio: (_) async {
                  plays++;
                },
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

      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await settle();
      }

      await tester.pumpWidget(app());
      await settle();
      expect(find.text('Explora le parolas'), findsOneWidget);
      expect(find.byType(LearningPracticePanel), findsNothing);
      await tap(find.text('Continuar')); // grammar only
      expect(find.text('Grammatica'), findsOneWidget);
      expect(find.byType(LearningPracticePanel), findsNothing);
      await tap(find.text('Continuar')); // first cloze
      expect(find.byType(LearningPracticePanel), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.byKey(const Key('practice-next')))
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byKey(const Key('practice-answer')), 'wrong');
      await settle();
      await tap(find.byKey(const Key('practice-check')));
      expect(history.events.where((e) => e.correct == false).length, 1);
      // Dispose everything and reload the stored session, as after closing the app.
      await tester.pumpWidget(const SizedBox());
      await settle();
      store = GuidedSessionStore();
      await tester.pumpWidget(app());
      await settle();
      expect(find.text('wrong'), findsOneWidget);
      expect(store.current!.index, 2);
      await tester.enterText(find.byKey(const Key('practice-answer')), 'es');
      await tap(find.byKey(const Key('practice-check')));
      await tap(find.byKey(const Key('practice-next')));
      expect(find.text('Dictato'), findsOneWidget);
      await tap(find.byKey(const Key('practice-audio')));
      expect(plays, 1);
      await tester.enterText(find.byKey(const Key('practice-answer')), 'puera');
      await tap(find.byKey(const Key('practice-check')));
      await tap(find.byKey(const Key('practice-next')));
      // A different cloze comes before the error's fresh retry.
      expect(store.current!.steps[store.current!.index], 'b');
      await tester.enterText(find.byKey(const Key('practice-answer')), 'es');
      await tap(find.byKey(const Key('practice-check')));
      await tap(find.byKey(const Key('practice-next')));
      expect(store.current!.steps[store.current!.index], 'a');
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('practice-answer')))
            .controller!
            .text,
        '',
      );
      await tester.enterText(find.byKey(const Key('practice-answer')), 'es');
      await tap(find.byKey(const Key('practice-check')));
      await tap(find.byKey(const Key('practice-next')));
      expect(find.text('Ben facite!'), findsOneWidget);
      expect(controller.isCompleted('lesson:basico1'), isTrue);
      expect(
        history.events
            .where((e) => e.activityId == 'a' && e.correct == true)
            .length,
        2,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
