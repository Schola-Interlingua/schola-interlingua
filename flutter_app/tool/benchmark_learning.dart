// flutter test tool/benchmark_learning.dart --reporter expanded
// Algorithm benchmark only; this does not measure frame rate or device startup.
import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/models/learning_practice.dart';
import 'package:schola_interlingua_flutter/src/services/guided_session_store.dart';
import 'package:schola_interlingua_flutter/src/services/learning_activity_catalog.dart';
import 'package:schola_interlingua_flutter/src/services/lesson_parts.dart';
import '../test/support/legacy_learning.dart';
import '../test/support/practice_history_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('compare course partition and session scheduling work', () async {
    final catalog = await LearningActivityCatalog.load();
    final slugs = catalog.termsBySource.keys.toList();
    final activities = historyActivities(120);
    final history = practiceHistory(2400, 115, 17);
    final now = DateTime(2026, 1, 4);
    for (var i = 0; i < 2; i++) {
      for (final slug in slugs) {
        lessonParts(catalog, slug);
        legacyLessonParts(catalog, slug);
      }
      selectSessionActivities(activities, history, now);
      legacySelectSessionActivities(activities, history, now);
    }
    int measure(String name, int rounds, int Function() action) {
      var checksum = 0;
      final clock = Stopwatch()..start();
      for (var i = 0; i < rounds; i++) {
        checksum += action();
      }
      clock.stop();
      // ignore: avoid_print
      print('$name: ${clock.elapsedMicroseconds} us, checksum=$checksum');
      return checksum;
    }

    expect(
      measure(
        'Course baseline, 100 passes / ${slugs.length} sources',
        100,
        () => slugs.fold(
          0,
          (sum, slug) => sum + legacyLessonParts(catalog, slug).length,
        ),
      ),
      measure(
        'Course cached, 100 passes',
        100,
        () => slugs.fold(
          0,
          (sum, slug) => sum + lessonParts(catalog, slug).length,
        ),
      ),
    );
    expect(
      measure(
        'Scheduling baseline, 10 sessions / 2400 events',
        10,
        () => legacySelectSessionActivities(activities, history, now).length,
      ),
      measure(
        'Scheduling indexed, 10 sessions',
        10,
        () => selectSessionActivities(activities, history, now).length,
      ),
    );
    expect(
      priorPracticeActivity(activities, history, 'source-0', DateTime(2027)),
      isNotNull,
    );
    for (final at in [DateTime(2027), now, DateTime(2025)]) {
      LearningActivity? legacyPrior() => activities.where((activity) {
        if (activity.sourceSlug == 'source-0') return false;
        final due = legacyPracticeDueAt(
          List.unmodifiable(history),
          activity.id,
        );
        return due != null && !due.isAfter(at);
      }).firstOrNull;
      legacyPrior();
      priorPracticeActivity(activities, history, 'source-0', at);
      expect(
        measure(
          'Session prior baseline at $at, 20 selections',
          20,
          () => legacyPrior()?.id.hashCode ?? 0,
        ),
        measure(
          'Session prior indexed at $at, 20 selections',
          20,
          () =>
              priorPracticeActivity(
                activities,
                history,
                'source-0',
                at,
              )?.id.hashCode ??
              0,
        ),
      );
    }
  });
}
