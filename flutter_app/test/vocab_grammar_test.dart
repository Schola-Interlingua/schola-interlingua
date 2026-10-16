import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/app_state.dart';
import 'package:schola_interlingua_flutter/src/data/course_seed.dart';
import 'package:schola_interlingua_flutter/src/data/vocab_grammar_topics.dart';
import 'package:schola_interlingua_flutter/src/models/course_models.dart';
import 'package:schola_interlingua_flutter/src/screens/lesson_screen.dart';
import 'package:schola_interlingua_flutter/src/theme/app_theme.dart';
import 'package:schola_interlingua_flutter/src/widgets/lesson_grammar.dart';
import 'package:schola_interlingua_flutter/src/widgets/practice_panel.dart';

void main() {
  test(
    'vocabulary notes cover grammatical units and belong to real course items',
    () {
      final courseSlugs = courseLevels
          .expand((level) => level.sections)
          .expand((section) => section.items)
          .where((item) => item.kind == CourseItemKind.vocabulary)
          .map((item) => item.slug)
          .toSet();
      expect(vocabGrammarTopics.length, 25);
      expect(courseSlugs, containsAll(vocabGrammarTopics.keys));
      expect(
        vocabGrammarTopics.keys,
        containsAll([
          'plurales',
          'adjectivos-possessive',
          'possessives2',
          'numeros',
          'prepositiones',
          'questiones',
          'demonstrativos1',
          'conjunctiones',
          'presente1',
          'verbos2',
          'verbos3',
          'verbos4',
          'verbos5',
          'verbos6',
          'adverbios1',
          'adverbios2',
          'adverbios3',
          'negativos',
          'datas-tempore',
        ]),
      );
      for (final topics in vocabGrammarTopics.values) {
        for (final topic in topics) {
          expect(topic.explanation!.split(' ').length, lessThanOrEqualTo(65));
          expect(Uri.parse(topic.source!).host, 'www.interlingua.com');
          expect(topic.sections, isNotEmpty);
          expect(topic.examples.length, inInclusiveRange(2, 3));
        }
      }
    },
  );

  testWidgets(
    'all vocabulary notes appear before practice and explore at 320px',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = AppController();
      await tester.runAsync(controller.loadVocab);
      for (final entry in vocabGrammarTopics.entries) {
        await tester.pumpWidget(
          AppStateScope(
            controller: controller,
            child: MaterialApp(
              theme: AppTheme.dark(),
              home: Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: VocabLessonScreen(slug: entry.key),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(controller.lessonItems(entry.key), isNotEmpty);
        final grammar = find.byType(LessonGrammar);
        final practice = find.byType(PracticePanel);
        expect(grammar, findsOneWidget);
        expect(
          tester.getTopLeft(grammar).dy,
          lessThan(tester.getTopLeft(practice).dy),
        );
        final topic = entry.value.single;
        expect(find.text(topic.explanation!), findsOneWidget);
        for (var index = 0; index < topic.examples.length; index++) {
          final option = find.byKey(ValueKey('lesson-grammar-example-$index'));
          await tester.ensureVisible(option);
          await tester.tap(option);
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<Text>(find.byKey(const Key('lesson-grammar-result')))
                .data,
            topic.examples[index].after,
          );
          expect(
            tester
                .widget<Text>(find.byKey(const Key('lesson-grammar-note')))
                .data,
            topic.examples[index].note,
          );
        }
        expect(find.byKey(const Key('grammar-progress')), findsNothing);
        expect(tester.takeException(), isNull, reason: entry.key);
      }
      // A lexical topic should not retain the previous unit's grammar card.
      await tester.pumpWidget(
        AppStateScope(
          controller: controller,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: VocabLessonScreen(slug: 'animales'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LessonGrammar), findsNothing);
      expect(find.byType(PracticePanel), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
