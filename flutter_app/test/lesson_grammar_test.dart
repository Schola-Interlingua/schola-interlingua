import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/data/lesson_grammar_topics.dart';
import 'package:schola_interlingua_flutter/src/data/web_content_loader.dart';
import 'package:schola_interlingua_flutter/src/theme/app_theme.dart';
import 'package:schola_interlingua_flutter/src/widgets/lesson_grammar.dart';

void main() {
  testWidgets(
    'every recorded lesson keeps all its grammar and explores its examples',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final contents = await tester.runAsync(
        () async => {
          for (final slug in lessonGrammarTopics.keys)
            slug: (await WebContentLoader.loadLection(slug))!,
        },
      );
      expect(contents!.length, 10);
      for (final entry in lessonGrammarTopics.entries) {
        final content = contents[entry.key]!;
        final indices =
            entry.value.expand((topic) => topic.bulletIndices).toList()..sort();
        // No old rule may disappear into the selector or be accidentally duplicated.
        expect(
          indices,
          List.generate(content.grammarBullets.length, (index) => index),
          reason: entry.key,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: LessonGrammar(
                  slug: entry.key,
                  bullets: content.grammarBullets,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (
          var topicIndex = 0;
          topicIndex < entry.value.length;
          topicIndex++
        ) {
          final topic = entry.value[topicIndex];
          final topicFinder = find.byKey(
            ValueKey('lesson-grammar-topic-$topicIndex'),
          );
          await tester.ensureVisible(topicFinder);
          await tester.tap(topicFinder);
          await tester.pumpAndSettle();
          final explanation = tester
              .widget<Text>(find.byKey(const Key('lesson-grammar-explanation')))
              .data!;
          for (final index in topic.bulletIndices) {
            expect(
              explanation,
              contains(content.grammarBullets[index].replaceAll('**', '')),
            );
          }
          for (var index = 0; index < topic.examples.length; index++) {
            final example = find.byKey(
              ValueKey('lesson-grammar-example-$index'),
            );
            await tester.ensureVisible(example);
            await tester.tap(example);
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
            expect(
              tester.takeException(),
              isNull,
              reason: '${entry.key}: ${topic.title}',
            );
          }
        }
        expect(find.textContaining('exercitios'), findsNothing);
        expect(find.textContaining('session'), findsNothing);
      }
    },
  );

  testWidgets(
    'topic changes preserve example choice; another lesson starts fresh at 320px',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      Widget app(String slug) => MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: LessonGrammar(
              slug: slug,
              bullets: const ['a', 'b', 'c', 'd', 'e'],
            ),
          ),
        ),
      );
      Future<void> tap(String key) async {
        final finder = find.byKey(ValueKey(key));
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(app('lection1'));
      await tap('lesson-grammar-example-1');
      await tap('lesson-grammar-topic-2');
      await tap('lesson-grammar-example-2');
      expect(find.text('nos es'), findsOneWidget);
      await tap('lesson-grammar-topic-0');
      expect(find.text('le appartamentos'), findsOneWidget);
      await tester.pumpWidget(app('lection2'));
      await tester.pumpAndSettle();
      expect(find.text('io me evelia'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
