import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schola_interlingua_flutter/src/models/learning_practice.dart';
import 'package:schola_interlingua_flutter/src/services/learning_activity_catalog.dart';
import 'package:schola_interlingua_flutter/src/services/learning_practice_store.dart';
import 'package:schola_interlingua_flutter/src/theme/app_theme.dart';
import 'package:schola_interlingua_flutter/src/widgets/learning_practice_panel.dart';

const cloze = LearningActivity(
  id: 'test-cloze',
  sourceSlug: 'test',
  mode: PracticeMode.cloze,
  prompt: 'Nos ____ interlingua.',
  answers: ['parla'],
  explanation: 'Le verbo non cambia con nos.',
);
const dictation = LearningActivity(
  id: 'test-dictation',
  sourceSlug: 'test',
  mode: PracticeMode.dictation,
  prompt: 'Ascolta e scribe in Interlingua.',
  answers: ['tu mangia un orange'],
  explanation: 'Compara le texto.',
  audioAsset: 'assets/audios/interlingua/tu_mangia_un_orange.wav',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => SharedPreferences.setMockInitialValues({'existing_progress': 'keep'}),
  );

  test(
    'curated clozes come from bundled sources and all dictations have real audio',
    () async {
      final catalog = await LearningActivityCatalog.load();
      final content =
          jsonDecode(await rootBundle.loadString('assets/data/content.json'))
              as Map;
      final vocab =
          jsonDecode(await rootBundle.loadString('assets/data/vocab.json'))
              as Map;
      final clozes = catalog.activities
          .where((a) => a.mode == PracticeMode.cloze)
          .toList();
      expect(clozes, hasLength(38));
      expect(
        catalog.activities.map((a) => a.id).toSet().length,
        catalog.activities.length,
      );
      for (final activity in clozes) {
        final source = activity.sourceSlug.startsWith('lection')
            ? (content['lections'][activity.sourceSlug]['paragraphs'] as List)
                  .join(' ')
            : (vocab[activity.sourceSlug] as List)
                  .map((r) => r['term'])
                  .join('\n');
        expect(source, contains(activity.sourceText!), reason: activity.id);
        expect(
          activity.prompt.split('____'),
          hasLength(2),
          reason: activity.id,
        );
        expect(
          activity.prompt.replaceFirst('____', activity.answers.first),
          activity.sourceText,
        );
        expect(activity.answers, isNotEmpty);
        expect(activity.explanation, isNotEmpty);
      }
      for (final slug in vocab.keys.where((slug) => slug != 'extra')) {
        expect(
          catalog.forSource(slug as String, PracticeMode.dictation),
          isNotEmpty,
          reason: slug,
        );
      }
      for (final activity in catalog.activities.where(
        (a) => a.mode == PracticeMode.dictation,
      )) {
        expect(
          File(activity.audioAsset!).existsSync(),
          isTrue,
          reason: activity.id,
        );
        expect(
          (vocab[activity.sourceSlug] as List).any(
            (r) => r['term'] == activity.answers.first,
          ),
          isTrue,
        );
      }
    },
  );

  test(
    'grading tolerates case, spacing and punctuation but rejects different words',
    () {
      expect(cloze.accepts(' PARLA. '), isTrue);
      expect(dictation.accepts('Tu   mangia un orange!'), isTrue);
      expect(cloze.accepts('parlava'), isFalse);
      expect(cloze.accepts(''), isFalse);
      expect(dictation.accepts('tu mangia un pomo'), isFalse);
    },
  );

  test(
    'history survives reload, serializes concurrent writes and preserves other data',
    () async {
      final store = LearningPracticeStore();
      PracticeEvent event(String id) => PracticeEvent(
        id: id,
        runId: 'run',
        activityId: cloze.id,
        sourceSlug: 'test',
        mode: PracticeMode.cloze,
        kind: PracticeEventKind.answer,
        at: DateTime(2026, 10, 16),
        support: const [],
        plays: 0,
        attemptNumber: 1,
        elapsedMs: 1200,
        answer: 'parla',
        correct: true,
      );
      await Future.wait([store.append(event('1')), store.append(event('2'))]);
      await store.append(event('1'));
      final reloaded = LearningPracticeStore();
      await reloaded.load();
      expect(reloaded.events.map((e) => e.id), ['1', '2']);
      expect(reloaded.events.first.independent, isTrue);
      expect(reloaded.events.first.answer, 'parla');
      expect(
        (await SharedPreferences.getInstance()).getString('existing_progress'),
        'keep',
      );
    },
  );

  testWidgets(
    'cloze tracks wrong attempts, hints, retries and reveal without duplicate submissions',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = LearningPracticeStore();
      await tester.runAsync(store.load);
      final next = LearningActivity(
        id: 'test-cloze-2',
        sourceSlug: 'test',
        mode: PracticeMode.cloze,
        prompt: 'Io ____ un libro.',
        answers: const ['ha'],
        explanation: 'Haber.',
      );
      final catalog = Future.value(
        LearningActivityCatalog([cloze, next, dictation]),
      );
      await tester.pumpWidget(_app(store: store, catalog: catalog));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      Future<void> tap(String key) async {
        final finder = find.byKey(Key(key));
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pumpAndSettle();
      }

      expect(
        find.byKey(const Key('practice-check')),
        findsOneWidget,
        reason: tester.allWidgets
            .whereType<Text>()
            .map((t) => t.data)
            .join(' | '),
      );
      await tap('practice-check');
      expect(store.events, isEmpty); // Empty input is not a learning attempt.
      await tester.enterText(
        find.byKey(const Key('practice-answer')),
        'parlava',
      );
      await tap('practice-check');
      expect(store.events.single.correct, isFalse);
      await tap('practice-hint');
      expect(store.events.last.kind, PracticeEventKind.hint);
      expect(find.text('Prime littera: p'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('practice-answer')), 'parla');
      await tap('practice-check');
      expect(store.events.last.correct, isTrue);
      expect(store.events.last.independent, isFalse);
      expect(store.events.last.support, containsAll(['retry', 'first-letter']));
      expect(store.events.last.attemptNumber, 2);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('practice-check')))
            .onPressed,
        isNull,
      );
      await tap('practice-next');
      await tap('practice-reveal');
      expect(store.events.last.kind, PracticeEventKind.reveal);
      expect(store.events.last.correct, isNull);
      expect(find.text('Mi practica'), findsNothing);
      expect(
        store.events.where((event) => event.kind == PracticeEventKind.answer),
        hasLength(2),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'dictation hides transcript, handles audio failures and tracks listening aids',
    (tester) async {
      final store = LearningPracticeStore();
      await tester.runAsync(store.load);
      var shouldFail = true;
      final assets = <String>[];
      await tester.pumpWidget(
        _app(
          store: store,
          catalog: Future.value(LearningActivityCatalog([dictation])),
          playAudio: (asset) async {
            if (shouldFail) throw StateError('offline');
            assets.add(asset);
          },
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      Future<void> tap(String key) async {
        await tester.ensureVisible(find.byKey(Key(key)));
        await tester.tap(find.byKey(Key(key)));
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pumpAndSettle();
      }

      expect(find.text(dictation.answers.first), findsNothing);
      await tester.enterText(
        find.byKey(const Key('practice-answer')),
        'tu mangia un orange',
      );
      await tap('practice-check');
      expect(store.events, isEmpty);
      expect(find.text('Ascolta le audio ante verificar.'), findsOneWidget);
      await tap('practice-audio');
      expect(store.events, isEmpty);
      expect(find.byKey(const Key('practice-error')), findsOneWidget);
      shouldFail = false;
      await tap('practice-audio');
      await tap('practice-audio');
      expect(assets, [dictation.audioAsset, dictation.audioAsset]);
      await tap('practice-check');
      expect(store.events.last.correct, isTrue);
      expect(store.events.last.plays, 2);
      expect(store.events.last.support, contains('replay'));
      expect(store.events.last.independent, isFalse);
      final reloaded = LearningPracticeStore();
      await tester.runAsync(reloaded.load);
      expect(reloaded.events.length, 3);
      expect(reloaded.events.last.answer, 'tu mangia un orange');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'first-attempt success is independent and navigation clears the previous exercise',
    (tester) async {
      final store = LearningPracticeStore();
      await tester.runAsync(store.load);
      final other = LearningActivity(
        id: 'other-cloze',
        sourceSlug: 'other',
        mode: PracticeMode.cloze,
        prompt: 'Tu ____ un libro.',
        answers: const ['ha'],
        explanation: 'Haber.',
      );
      final catalog = Future.value(
        LearningActivityCatalog([cloze, dictation, other]),
      );
      await tester.pumpWidget(_app(store: store, catalog: catalog));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('practice-answer')),
        'Parla!',
      );
      await tester.ensureVisible(find.byKey(const Key('practice-check')));
      await tester.tap(find.byKey(const Key('practice-check')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(store.events.single.independent, isTrue);
      await tester.pumpWidget(
        _app(store: store, catalog: catalog, slug: 'other'),
      );
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(find.text('Tu ____ un libro.'), findsOneWidget);
      expect(find.byKey(const Key('practice-feedback')), findsNothing);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('practice-answer')))
            .controller!
            .text,
        isEmpty,
      );
      expect(store.forSource('test'), hasLength(1));
      expect(store.forSource('other'), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app({
  required LearningPracticeStore store,
  required Future<LearningActivityCatalog> catalog,
  String slug = 'test',
  Future<void> Function(String)? playAudio,
}) => MaterialApp(
  theme: AppTheme.dark(),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: LearningPracticePanel(
        slug: slug,
        store: store,
        catalog: catalog,
        playAudio: playAudio,
      ),
    ),
  ),
);
