import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_practice.dart';

/// A clean answer schedules a later review. Errors and help stay due until
/// recalled independently in a fresh exercise run. Audio replay alone is normal.
DateTime? practiceDueAt(List<PracticeEvent> events, String activityId) {
  final relevant =
      events
          .where(
            (e) =>
                e.activityId == activityId && e.kind != PracticeEventKind.audio,
          )
          .toList()
        ..sort((a, b) => a.at.compareTo(b.at));
  return _dueFromSortedEvents(relevant);
}

/// Group once, then sort only the activities actually considered for review.
/// A session that finds its first due activity early need not sort all history.
class PracticeDueIndex {
  PracticeDueIndex(List<PracticeEvent> events) {
    for (final event in events) {
      if (event.kind == PracticeEventKind.audio) continue;
      _grouped.putIfAbsent(event.activityId, () => []).add(event);
    }
  }
  final _grouped = <String, List<PracticeEvent>>{};
  final _dates = <String, DateTime>{};
  DateTime? dueAt(String id) {
    final events = _grouped[id];
    if (events == null) return null;
    return _dates.putIfAbsent(
      id,
      () => _dueFromSortedEvents(events..sort((a, b) => a.at.compareTo(b.at)))!,
    );
  }
}

LearningActivity? priorPracticeActivity(
  List<LearningActivity> activities,
  List<PracticeEvent> events,
  String sourceSlug,
  DateTime now,
) {
  if (events.isEmpty) return null;
  PracticeDueIndex? dates;
  var checked = 0;
  for (final activity in activities) {
    if (activity.sourceSlug == sourceSlug) continue;
    // Keep the common early match cheap; build the full index only when the
    // search continues, instead of repeatedly scanning a large history.
    final due = ++checked <= 3
        ? practiceDueAt(events, activity.id)
        : (dates ??= PracticeDueIndex(events)).dueAt(activity.id);
    if (due != null && !due.isAfter(now)) return activity;
  }
  return null;
}

DateTime? _dueFromSortedEvents(List<PracticeEvent> relevant) {
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

List<LearningActivity> selectSessionActivities(
  List<LearningActivity> activities,
  List<PracticeEvent> events,
  DateTime now,
) {
  final dueDates = PracticeDueIndex(events);
  final candidates =
      activities.where((item) {
        final due = dueDates.dueAt(item.id);
        return due == null || !due.isAfter(now);
      }).toList()..sort((a, b) {
        int priority(LearningActivity item) {
          final due = dueDates.dueAt(item.id);
          return due == null
              ? 1
              : !due.isAfter(now)
              ? 0
              : 2;
        }

        final order = priority(a).compareTo(priority(b));
        if (order != 0) return order;
        final ad = dueDates.dueAt(a.id);
        final bd = dueDates.dueAt(b.id);
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

class GuidedSession {
  const GuidedSession({
    required this.slug,
    required this.id,
    required this.steps,
    this.index = 0,
    this.draft = '',
    this.repeated = const [],
    this.partId,
    this.partIndex = 0,
    this.partCount = 1,
    this.isReview = false,
  });
  final String slug, id, draft;
  final List<String> steps, repeated;
  final int index;
  final String? partId;
  final int partIndex, partCount;
  final bool isReview;
  String get runId => '$id-$index';
  GuidedSession copy({
    List<String>? steps,
    int? index,
    String? draft,
    List<String>? repeated,
    String? partId,
    int? partIndex,
    int? partCount,
    bool? isReview,
  }) => GuidedSession(
    slug: slug,
    id: id,
    steps: steps ?? this.steps,
    index: index ?? this.index,
    draft: draft ?? this.draft,
    repeated: repeated ?? this.repeated,
    partId: partId ?? this.partId,
    partIndex: partIndex ?? this.partIndex,
    partCount: partCount ?? this.partCount,
    isReview: isReview ?? this.isReview,
  );
  GuidedSession advance({bool needsReview = false}) {
    final updatedSteps = [...steps];
    final updatedRepeated = [...repeated];
    final activityId = steps[index];
    if (needsReview && !repeated.contains(activityId)) {
      updatedSteps.insert((index + 3).clamp(0, steps.length - 1), activityId);
      updatedRepeated.add(activityId);
    }
    return copy(
      steps: updatedSteps,
      index: index + 1,
      draft: '',
      repeated: updatedRepeated,
    );
  }

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'id': id,
    'steps': steps,
    'index': index,
    'draft': draft,
    'repeated': repeated,
    'partId': partId,
    'partIndex': partIndex,
    'partCount': partCount,
    'isReview': isReview,
  };
  factory GuidedSession.fromJson(Map<String, dynamic> json) => GuidedSession(
    slug: json['slug'] as String,
    id: json['id'] as String,
    steps: List<String>.from(json['steps'] as List),
    index: json['index'] as int,
    draft: json['draft'] as String? ?? '',
    repeated: List<String>.from(json['repeated'] as List? ?? []),
    partId: json['partId'] as String?,
    partIndex: json['partIndex'] as int? ?? 0,
    partCount: json['partCount'] as int? ?? 1,
    isReview: json['isReview'] as bool? ?? false,
  );
}

class GuidedSessionStore extends ChangeNotifier {
  static final instance = GuidedSessionStore();
  static const storageKey = 'guided_session_v1';
  GuidedSession? get current => _current;
  GuidedSession? _current;
  final Map<String, GuidedSession> _sessions = {};
  GuidedSession? forSource(String slug) => _sessions[slug];
  final Map<String, Set<String>> _completedParts = {};
  final Map<String, GuidedSession> _partSessions = {};
  Set<String> completedParts(String slug) =>
      Set.unmodifiable(_completedParts[slug] ?? {});
  GuidedSession? forPart(String slug, String partId) =>
      _partSessions['$slug:$partId'];
  int nextPartIndex(String slug, int total) {
    for (var i = 0; i < total; i++) {
      if (!completedParts(slug).contains('$slug-part-${i + 1}')) return i;
    }
    return total;
  }

  Future<void>? _loading;
  Future<void> _writes = Future.value();
  Future<void> load() => _loading ??= _load().catchError((Object e) {
    _loading = null;
    throw e;
  });
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw != null) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry
            in (data['sessions'] as Map<String, dynamic>).entries) {
          final value = GuidedSession.fromJson(
            entry.value as Map<String, dynamic>,
          );
          if (value.index >= 0 && value.index < value.steps.length) {
            _sessions[entry.key] = value;
          }
        }
        for (final entry
            in (data['completedParts'] as Map<String, dynamic>? ?? {})
                .entries) {
          _completedParts[entry.key] = Set<String>.from(entry.value as List);
        }
        for (final entry
            in (data['partSessions'] as Map<String, dynamic>? ?? {}).entries) {
          final value = GuidedSession.fromJson(
            entry.value as Map<String, dynamic>,
          );
          if (value.index >= 0 && value.index < value.steps.length) {
            _partSessions[entry.key] = value;
          }
        }
        _current = _sessions[data['current']];
      } on FormatException {
        /* A damaged cursor must not block the course. */
      } on TypeError {
        /* Ignore obsolete local formats. */
      }
    }
  }

  Future<void> save(GuidedSession session) {
    final operation = _writes.then((_) async {
      await load();
      final prefs = await SharedPreferences.getInstance();
      final updated = {..._sessions, session.slug: session};
      final completed = {
        for (final entry in _completedParts.entries)
          entry.key: {...entry.value},
      };
      final partSessions = {..._partSessions};
      if (session.partId != null) {
        partSessions['${session.slug}:${session.partId}'] = session;
        if (session.steps[session.index] == 'finish' && !session.isReview) {
          completed.putIfAbsent(session.slug, () => {}).add(session.partId!);
        }
      }
      if (!await prefs.setString(
        storageKey,
        jsonEncode({
          'current': session.slug,
          'completedParts': completed.map(
            (key, value) => MapEntry(key, value.toList()),
          ),
          'partSessions': partSessions.map(
            (key, value) => MapEntry(key, value.toJson()),
          ),
          'sessions': updated.map(
            (key, value) => MapEntry(key, value.toJson()),
          ),
        }),
      )) {
        throw StateError('Could not save session');
      }
      _completedParts
        ..clear()
        ..addAll(completed);
      _partSessions
        ..clear()
        ..addAll(partSessions);
      _current = session;
      _sessions[session.slug] = session;
      notifyListeners();
    });
    _writes = operation.catchError((Object _) {});
    return operation;
  }
}
