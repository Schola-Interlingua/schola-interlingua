import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/data/course_seed.dart';
import 'package:schola_interlingua_flutter/src/data/grammar_curriculum.dart';
import 'package:schola_interlingua_flutter/src/data/grammar_lessons.dart';
import 'package:schola_interlingua_flutter/src/models/course_models.dart';
import 'package:schola_interlingua_flutter/src/screens/appendix_screen.dart';
import 'package:schola_interlingua_flutter/src/theme/app_theme.dart';

void main() {
  test('all six levels expose every grammar topic exactly once', () {
    final assigned = <String>[];
    expect(courseLevels, hasLength(6));
    for (final level in courseLevels) {
      final section = level.sections.singleWhere(
        (section) => section.kind == LevelSectionKind.grammatica,
      );
      expect(section.items, hasLength(3));
      expect(level.sections.first, section);
      for (final item in section.items) {
        expect(item.kind, CourseItemKind.appendix);
        final topic = grammarLessonForSlug(item.slug);
        expect(topic, isNotNull, reason: '${level.slug}: ${item.slug}');
        expect(item.title, topic!.title);
        expect(grammarForLevel(level.slug), contains(topic));
        assigned.add(topic.id);
      }
    }
    expect(assigned, hasLength(18));
    expect(assigned.toSet(), grammarLessons.map((topic) => topic.id).toSet());
    expect(assigned.toSet().length, assigned.length);
    expect(grammarLessonForSlug('grammatica-missing'), isNull);
  });

  testWidgets(
    'each course grammar destination opens directly and resets at 320px',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final level in courseLevels) {
        for (final topic in grammarForLevel(level.slug)) {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.dark(),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: AppendixScreen(slug: 'grammatica-${topic.id}'),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text(topic.title), findsOneWidget);
          expect(find.text('Selige un thema'), findsNothing);
          expect(find.byKey(const Key('grammar-feedback')), findsNothing);
          final example = find.byKey(ValueKey('grammar-example-${topic.id}-1'));
          await tester.ensureVisible(example);
          await tester.tap(example);
          await tester.pumpAndSettle();
          expect(find.text(topic.examples[1].after), findsOneWidget);
          final answer = find.byKey(
            ValueKey('grammar-answer-${topic.questions.first.answer}'),
          );
          await tester.ensureVisible(answer);
          await tester.tap(answer);
          await tester.pumpAndSettle();
          expect(find.textContaining('Correcte!'), findsOneWidget);
          expect(tester.takeException(), isNull, reason: topic.id);
        }
      }
    },
  );
}
