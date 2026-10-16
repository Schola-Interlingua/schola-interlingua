// Baseline captured before the learning performance changes. Keep this independent
// of the optimized algorithms to detect ordering or partition regressions.
import 'dart:math' as math;
import 'package:schola_interlingua_flutter/src/data/lesson_grammar_topics.dart';
import 'package:schola_interlingua_flutter/src/data/vocab_grammar_topics.dart';
import 'package:schola_interlingua_flutter/src/models/learning_practice.dart';
import 'package:schola_interlingua_flutter/src/services/learning_activity_catalog.dart';
import 'package:schola_interlingua_flutter/src/services/lesson_parts.dart';

/// A clean answer schedules a later review. Errors and help stay due until
/// recalled independently in a fresh exercise run. Audio replay alone is normal.
DateTime? legacyPracticeDueAt(List<PracticeEvent> events, String activityId) {
  final relevant =
      events
          .where(
            (e) =>
                e.activityId == activityId && e.kind != PracticeEventKind.audio,
          )
          .toList()
        ..sort((a, b) => a.at.compareTo(b.at));
  if (relevant.isEmpty) return null;
  final last = relevant.last;
  final clean =
      last.kind == PracticeEventKind.answer &&
      last.correct == true &&
      last.attemptNumber == 1 &&
      last.support.every((s) => s == 'replay');
  if (!clean) return last.at;
  var successes = 0;
  for (final event in relevant.reversed) {
    if (event.kind != PracticeEventKind.answer ||
        event.correct != true ||
        event.attemptNumber != 1 ||
        event.support.any((s) => s != 'replay')) {
      break;
    }
    successes++;
  }
  return last.at.add(
    Duration(
      days: successes >= 3
          ? 7
          : successes >= 2
          ? 3
          : 1,
    ),
  );
}

List<LearningActivity> legacySelectSessionActivities(
  List<LearningActivity> activities,
  List<PracticeEvent> events,
  DateTime now,
) {
  final candidates =
      activities.where((item) {
        final due = legacyPracticeDueAt(events, item.id);
        return due == null || !due.isAfter(now);
      }).toList()..sort((a, b) {
        int priority(LearningActivity item) {
          final due = legacyPracticeDueAt(events, item.id);
          return due == null
              ? 1
              : !due.isAfter(now)
              ? 0
              : 2;
        }

        final order = priority(a).compareTo(priority(b));
        if (order != 0) return order;
        final ad = legacyPracticeDueAt(events, a.id);
        final bd = legacyPracticeDueAt(events, b.id);
        return ad != null && bd != null
            ? ad.compareTo(bd)
            : a.id.compareTo(b.id);
      });
  // Alternate writing and listening when both are available, without losing
  // the priority of due mistakes within each mode.
  final selected = <LearningActivity>[];
  while (selected.length < 6 && candidates.isNotEmpty) {
    final other = selected.isEmpty
        ? -1
        : candidates.indexWhere((a) => a.mode != selected.last.mode);
    selected.add(candidates.removeAt(other < 0 ? 0 : other));
  }
  return selected;
}

/// Stable content partitions: every existing exercise belongs to exactly one
/// part. Review scheduling never removes required content from a part.
List<LessonPart> legacyLessonParts(
  LearningActivityCatalog catalog,
  String slug,
) {
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
