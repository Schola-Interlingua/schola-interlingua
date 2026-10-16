enum PracticeMode { cloze, dictation }

enum PracticeEventKind { answer, hint, reveal, audio }

String normalizePracticeAnswer(String input) => input
    .toLowerCase()
    .replaceAll(RegExp(r'''[.,!?;:“”"…]'''), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

class LearningActivity {
  const LearningActivity({
    required this.id,
    required this.sourceSlug,
    required this.mode,
    required this.prompt,
    required this.answers,
    required this.explanation,
    this.audioAsset,
    this.sourceText,
  });
  final String id;
  final String sourceSlug;
  final PracticeMode mode;
  final String prompt;
  final List<String> answers;
  final String explanation;
  final String? audioAsset;
  final String? sourceText;
  bool accepts(String value) => answers.any(
    (answer) =>
        normalizePracticeAnswer(answer) == normalizePracticeAnswer(value),
  );
}

/// New practice has its own local history; it does not advance vocabulary SRS.
class PracticeEvent {
  const PracticeEvent({
    required this.id,
    required this.runId,
    required this.activityId,
    required this.sourceSlug,
    required this.mode,
    required this.kind,
    required this.at,
    required this.support,
    required this.plays,
    required this.attemptNumber,
    required this.elapsedMs,
    this.answer,
    this.correct,
  });
  final String id, runId, activityId, sourceSlug;
  final PracticeMode mode;
  final PracticeEventKind kind;
  final DateTime at;
  final List<String> support;
  final int plays, attemptNumber, elapsedMs;
  final String? answer;
  final bool? correct;
  bool get independent =>
      kind == PracticeEventKind.answer &&
      correct == true &&
      support.isEmpty &&
      attemptNumber == 1;

  Map<String, dynamic> toJson() => {
    'id': id,
    'runId': runId,
    'activityId': activityId,
    'sourceSlug': sourceSlug,
    'mode': mode.name,
    'kind': kind.name,
    'at': at.toIso8601String(),
    'support': support,
    'plays': plays,
    'attemptNumber': attemptNumber,
    'elapsedMs': elapsedMs,
    'answer': answer,
    'correct': correct,
  };
  factory PracticeEvent.fromJson(Map<String, dynamic> json) => PracticeEvent(
    id: json['id'] as String,
    runId: json['runId'] as String,
    activityId: json['activityId'] as String,
    sourceSlug: json['sourceSlug'] as String,
    mode: PracticeMode.values.byName(json['mode'] as String),
    kind: PracticeEventKind.values.byName(json['kind'] as String),
    at: DateTime.parse(json['at'] as String),
    support: List<String>.from(json['support'] as List),
    plays: json['plays'] as int,
    attemptNumber: json['attemptNumber'] as int,
    elapsedMs: json['elapsedMs'] as int,
    answer: json['answer'] as String?,
    correct: json['correct'] as bool?,
  );
}
