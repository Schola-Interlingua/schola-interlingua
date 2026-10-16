import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/models/learning_practice.dart';
import 'package:schola_interlingua_flutter/src/services/guided_session_store.dart';
import 'package:schola_interlingua_flutter/src/services/learning_activity_catalog.dart';
import 'package:schola_interlingua_flutter/src/services/lesson_parts.dart';
import 'support/legacy_learning.dart';
import 'support/practice_history_fixture.dart';

Object partitionSnapshot(List<LessonPart> parts) => [
  for (final part in parts)
    [
      part.id,
      part.index,
      part.grammarIndex,
      part.activities.map((a) => a.id).toList(),
      part.terms,
    ],
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'indexes preserve order, first ID match and caller-owned sort results',
    () {
      final activities = historyActivities(30);
      final first = activities.first;
      activities.add(
        LearningActivity(
          id: first.id,
          sourceSlug: 'duplicate',
          mode: PracticeMode.cloze,
          prompt: 'duplicate',
          answers: ['x'],
          explanation: 'x',
        ),
      );
      final terms = <String, List<String>>{
        'source-0': ['original'],
      };
      final catalog = LearningActivityCatalog(activities, termsBySource: terms);
      expect(catalog.activityById(first.id), same(first));
      expect(catalog.activityById('missing'), isNull);
      for (final slug in ['source-0', 'source-1', 'duplicate', 'missing']) {
        expect(
          catalog.activitiesForSource(slug),
          activities.where((a) => a.sourceSlug == slug).toList(),
        );
        for (final mode in PracticeMode.values) {
          final expected = activities
              .where((a) => a.sourceSlug == slug && a.mode == mode)
              .toList();
          final editable = catalog.forSource(slug, mode);
          expect(editable, expected);
          editable.clear();
          expect(catalog.forSource(slug, mode), expected);
        }
      }
      activities.clear();
      terms['source-0']!.add('later mutation');
      expect(catalog.activities, hasLength(31));
      expect(catalog.termsBySource['source-0'], ['original']);
      expect(() => catalog.activities.clear(), throwsUnsupportedError);
      expect(
        () => catalog.activitiesForSource('source-0').clear(),
        throwsUnsupportedError,
      );
    },
  );

  test(
    'cached parts exactly preserve real content partitions across all sources',
    () async {
      final catalog = await LearningActivityCatalog.load();
      for (final slug in [...catalog.termsBySource.keys, 'missing']) {
        final parts = lessonParts(catalog, slug);
        expect(
          partitionSnapshot(parts),
          partitionSnapshot(legacyLessonParts(catalog, slug)),
          reason: slug,
        );
        expect(lessonParts(catalog, slug), same(parts));
        expect(() => parts.clear(), throwsUnsupportedError);
        expect(() => parts.first.terms.clear(), throwsUnsupportedError);
        expect(() => parts.first.activities.clear(), throwsUnsupportedError);
      }
      final next = LearningActivityCatalog(historyActivities(5));
      expect(
        lessonParts(next, 'source-0'),
        isNot(same(lessonParts(catalog, 'source-0'))),
      );
      expect(
        lessonParts(next, 'source-0').first.activities.first.id,
        'activity-0',
      );
    },
  );

  test(
    'batched history preserves due dates and selection with unsorted and tied events',
    () {
      final activities = historyActivities(100);
      final now = DateTime(2026, 1, 4);
      for (var seed = 0; seed < 8; seed++) {
        final events = practiceHistory(1800, 95, seed);
        final before = events.map((e) => e.id).toList();
        final dates = PracticeDueIndex(events);
        for (final activity in activities) {
          expect(
            dates.dueAt(activity.id),
            legacyPracticeDueAt(events, activity.id),
            reason: '${activity.id}, seed $seed',
          );
          expect(practiceDueAt(events, activity.id), dates.dueAt(activity.id));
        }
        expect(
          selectSessionActivities(activities, events, now).map((a) => a.id),
          legacySelectSessionActivities(
            activities,
            events,
            now,
          ).map((a) => a.id),
        );
        expect(events.map((e) => e.id), before);
        for (final source in ['source-0', 'source-5', 'missing']) {
          for (final at in [DateTime(2025), now, DateTime(2027)]) {
            final legacy = activities.where((a) {
              if (a.sourceSlug == source) return false;
              final due = legacyPracticeDueAt(events, a.id);
              return due != null && !due.isAfter(at);
            }).firstOrNull;
            expect(
              priorPracticeActivity(activities, events, source, at),
              same(legacy),
            );
          }
        }
      }
      expect(PracticeDueIndex([]).dueAt('missing'), isNull);
      expect(priorPracticeActivity(activities, [], 'source-0', now), isNull);
      expect(
        selectSessionActivities(activities, [], now),
        legacySelectSessionActivities(activities, [], now),
      );
    },
  );
}
