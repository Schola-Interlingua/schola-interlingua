import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/data/grammar_lessons.dart';
import 'package:schola_interlingua_flutter/src/data/web_content_loader.dart';
import 'package:schola_interlingua_flutter/src/theme/app_theme.dart';
import 'package:schola_interlingua_flutter/src/widgets/grammar_workshop.dart';

void main() {
  test(
    'teaching data has distinct topics, valid answers and official sources',
    () {
      expect(
        grammarLessons.map((lesson) => lesson.id).toSet().length,
        grammarLessons.length,
      );
      for (final lesson in grammarLessons) {
        expect(Uri.parse(lesson.source).host, 'www.interlingua.com');
        for (final question in lesson.questions) {
          expect(
            question.answer,
            inInclusiveRange(0, question.options.length - 1),
          );
          expect(question.options.toSet().length, question.options.length);
          expect(question.explanation, isNotEmpty);
        }
      }
    },
  );

  testWidgets(
    'all topics support exploration, feedback, retry and completion at 390px',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(child: GrammarWorkshop()),
          ),
        ),
      );
      var completed = 0;
      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      for (final lesson in grammarLessons) {
        await tap(find.byKey(ValueKey('grammar-topic-${lesson.id}')));
        for (var index = 0; index < lesson.examples.length; index++) {
          await tap(
            find.byKey(ValueKey('grammar-example-${lesson.id}-$index')),
          );
          expect(find.text(lesson.examples[index].after), findsOneWidget);
        }
        for (var index = 0; index < lesson.questions.length; index++) {
          final question = lesson.questions[index];
          final wrong = (question.answer + 1) % question.options.length;
          await tap(find.byKey(ValueKey('grammar-answer-$wrong')));
          expect(
            tester.widget<Text>(find.byKey(const Key('grammar-feedback'))).data,
            startsWith('Non ancora.'),
          );
          await tap(find.byKey(ValueKey('grammar-answer-${question.answer}')));
          expect(
            tester.widget<Text>(find.byKey(const Key('grammar-feedback'))).data,
            startsWith('Correcte!'),
          );
          completed++;
          expect(
            tester.widget<Text>(find.byKey(const Key('grammar-progress'))).data,
            startsWith('$completed / 16'),
          );
          if (index < lesson.questions.length - 1) {
            await tap(find.byKey(const Key('grammar-next-question')));
          }
        }
        expect(tester.takeException(), isNull, reason: lesson.id);
      }
      expect(find.textContaining('Tu ha completate tote'), findsOneWidget);
      await tap(find.text('Refacer iste thema'));
      expect(
        tester.widget<Text>(find.byKey(const Key('grammar-progress'))).data,
        startsWith('14 / 16'),
      );
      expect(find.byKey(const Key('grammar-feedback')), findsNothing);
      await tap(find.byKey(const ValueKey('grammar-topic-articulos')));
      expect(find.byKey(const Key('grammar-feedback')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('grammar-progress'))).data,
        startsWith('14 / 16'),
      );
    },
  );

  testWidgets(
    'present examples retain the infinitive vowel at 320px in dark mode',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: SingleChildScrollView(child: GrammarWorkshop()),
          ),
        ),
      );
      final topic = find.byKey(const ValueKey('grammar-topic-presente'));
      await tester.ensureVisible(topic);
      await tester.tap(topic);
      await tester.pumpAndSettle();
      final example = find.byKey(const ValueKey('grammar-example-presente-2'));
      await tester.ensureVisible(example);
      await tester.tap(example);
      await tester.pumpAndSettle();
      expect(find.text('illa audi · illes audi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'active reference corrects present endings and lesson 3 has grammar',
    (tester) async {
      final reference = await tester.runAsync(
        () => WebContentLoader.loadAppendix('grammatica'),
      );
      final verbs = reference!.sections.first.bullets.join(' ');
      expect(verbs, contains('vider → vide'));
      expect(verbs, contains('audir → audi'));
      expect(verbs, isNot(contains('-a (presente)')));
      final lesson = await tester.runAsync(
        () => WebContentLoader.loadLection('lection3'),
      );
      expect(lesson!.grammarBullets, hasLength(3));
    },
  );
}
