import 'dart:math' as math;
import '../data/lesson_grammar_topics.dart';
import '../data/vocab_grammar_topics.dart';
import '../models/learning_practice.dart';
import 'learning_activity_catalog.dart';

class LessonPart {
  const LessonPart({
    required this.id,
    required this.index,
    required this.activities,
    required this.terms,
    this.grammarIndex,
  });
  final String id;
  final int index;
  final List<LearningActivity> activities;
  final List<String> terms;
  final int? grammarIndex;
}

/// Stable content partitions: every existing exercise belongs to exactly one
/// part. Review scheduling never removes required content from a part.
List<LessonPart> lessonParts(LearningActivityCatalog catalog, String slug) {
  final activities = catalog.activities
      .where((a) => a.sourceSlug == slug)
      .toList();
  final clozes = activities.where((a) => a.mode == PracticeMode.cloze).toList();
  final dictations = activities
      .where((a) => a.mode == PracticeMode.dictation)
      .toList();
  final ordered = <LearningActivity>[];
  for (var i = 0; i < math.max(clozes.length, dictations.length); i++) {
    if (i < clozes.length) ordered.add(clozes[i]);
    if (i < dictations.length) ordered.add(dictations[i]);
  }
  final topics = lessonGrammarTopics[slug] ?? vocabGrammarTopics[slug] ?? [];
  final terms =
      catalog.termsBySource[slug] ??
      dictations.map((a) => a.answers.first).toList();
  final count = math.max(
    1,
    math.max(
      topics.length,
      math.max((ordered.length / 4).ceil(), (terms.length / 4).ceil()),
    ),
  );
  final chunks = List.generate(
    count,
    (i) => ordered.skip(i * 4).take(4).toList(),
  );
  final wordGroups = [
    for (final chunk in chunks)
      chunk
          .where((a) => a.mode == PracticeMode.dictation)
          .map((a) => a.answers.first)
          .toList(),
  ];
  final covered = wordGroups.expand((words) => words).toSet();
  for (final term in terms.where((term) => !covered.contains(term))) {
    var smallest = 0;
    for (var i = 1; i < count; i++) {
      if (wordGroups[i].length < wordGroups[smallest].length) smallest = i;
    }
    wordGroups[smallest].add(term);
  }
  return [
    for (var i = 0; i < count; i++)
      LessonPart(
        id: '$slug-part-${i + 1}',
        index: i,
        activities: chunks[i],
        terms: wordGroups[i],
        grammarIndex: i < topics.length ? i : null,
      ),
  ];
}
