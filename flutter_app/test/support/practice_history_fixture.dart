import 'dart:math';
import 'package:schola_interlingua_flutter/src/models/learning_practice.dart';

List<LearningActivity> historyActivities(int count) => [
  for (var i = 0; i < count; i++)
    LearningActivity(
      id: 'activity-$i',
      sourceSlug: 'source-${i % 10}',
      mode: PracticeMode.values[i % 2],
      prompt: 'Prompt $i',
      answers: ['answer $i'],
      explanation: 'Explanation $i',
    ),
];

List<PracticeEvent> practiceHistory(int count, int activityCount, int seed) {
  final random = Random(seed);
  final start = DateTime(2026, 1, 1);
  return [
    for (var i = 0; i < count; i++)
      PracticeEvent(
        id: 'event-$i',
        runId: 'run-${i ~/ 10}',
        activityId: 'activity-${random.nextInt(activityCount)}',
        sourceSlug: 'source-${i % 10}',
        mode: PracticeMode.values[i % 2],
        kind: PracticeEventKind.values[random.nextInt(4)],
        at: start.add(Duration(hours: random.nextInt(100))),
        support: <List<String>>[
          [],
          ['replay'],
          ['hint'],
        ][random.nextInt(3)],
        plays: random.nextInt(3),
        attemptNumber: 1 + random.nextInt(2),
        elapsedMs: i,
        correct: [true, false, null][random.nextInt(3)],
      ),
  ]..shuffle(random);
}
