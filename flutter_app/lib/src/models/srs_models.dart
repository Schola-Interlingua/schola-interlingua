enum SrsStage { newWord, learning, reviewing, mastered }

class SrsCardProgress {
  const SrsCardProgress({
    required this.cardId,
    required this.stage,
    required this.intervalDays,
    required this.ease,
    required this.successCount,
    required this.failureCount,
    required this.dueAt,
    required this.seenAt,
    required this.updatedAt,
    this.lastReviewedAt,
  });

  final String cardId;
  final SrsStage stage;
  final int intervalDays;
  final double ease;
  final int successCount;
  final int failureCount;
  final DateTime dueAt;
  final DateTime seenAt;
  final DateTime updatedAt;
  final DateTime? lastReviewedAt;

  bool get isDue => !dueAt.isAfter(DateTime.now());

  SrsCardProgress copyWith({
    SrsStage? stage,
    int? intervalDays,
    double? ease,
    int? successCount,
    int? failureCount,
    DateTime? dueAt,
    DateTime? seenAt,
    DateTime? updatedAt,
    DateTime? lastReviewedAt,
  }) {
    return SrsCardProgress(
      cardId: cardId,
      stage: stage ?? this.stage,
      intervalDays: intervalDays ?? this.intervalDays,
      ease: ease ?? this.ease,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      dueAt: dueAt ?? this.dueAt,
      seenAt: seenAt ?? this.seenAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'card_id': cardId,
      'stage': stage.name,
      'interval_days': intervalDays,
      'ease': ease,
      'success_count': successCount,
      'failure_count': failureCount,
      'due_at': dueAt.toIso8601String(),
      'seen_at': seenAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
    };
  }

  static SrsCardProgress fromJson(String cardId, Map<String, dynamic> json) {
    final String stageName = json['stage']?.toString() ?? SrsStage.newWord.name;
    return SrsCardProgress(
      cardId: cardId,
      stage: SrsStage.values.firstWhere(
        (SrsStage value) => value.name == stageName,
        orElse: () => SrsStage.newWord,
      ),
      intervalDays: (json['interval_days'] as num?)?.toInt() ?? 0,
      ease: (json['ease'] as num?)?.toDouble() ?? 2.3,
      successCount: (json['success_count'] as num?)?.toInt() ?? 0,
      failureCount: (json['failure_count'] as num?)?.toInt() ?? 0,
      dueAt:
          DateTime.tryParse(json['due_at']?.toString() ?? '') ?? DateTime.now(),
      seenAt:
          DateTime.tryParse(json['seen_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      lastReviewedAt: DateTime.tryParse(
        json['last_reviewed_at']?.toString() ?? '',
      ),
    );
  }
}
