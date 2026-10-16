import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/learning_practice.dart';
import 'option_audio_service.dart';

class LearningActivityCatalog {
  LearningActivityCatalog(
    List<LearningActivity> activities, {
    Map<String, List<String>> termsBySource = const {},
  }) : activities = List.unmodifiable(activities),
       termsBySource = Map.unmodifiable({
         for (final entry in termsBySource.entries)
           entry.key: List<String>.unmodifiable(entry.value),
       });
  final Map<String, List<String>> termsBySource;
  final List<LearningActivity> activities;
  late final Map<String, LearningActivity> _byId = _indexIds();
  late final Map<String, List<LearningActivity>> _bySource = _indexSources();
  late final Map<(String, PracticeMode), List<LearningActivity>> _byMode = {
    for (final entry in _bySource.entries)
      for (final mode in PracticeMode.values)
        (entry.key, mode): List.unmodifiable(
          entry.value.where((activity) => activity.mode == mode),
        ),
  };

  Map<String, LearningActivity> _indexIds() {
    final result = <String, LearningActivity>{};
    for (final activity in activities) {
      // Preserve the previous first-match lookup, even for duplicate IDs.
      result.putIfAbsent(activity.id, () => activity);
    }
    return result;
  }

  Map<String, List<LearningActivity>> _indexSources() {
    final result = <String, List<LearningActivity>>{};
    for (final activity in activities) {
      result.putIfAbsent(activity.sourceSlug, () => []).add(activity);
    }
    return {
      for (final entry in result.entries)
        entry.key: List.unmodifiable(entry.value),
    };
  }

  LearningActivity? activityById(String id) => _byId[id];
  List<LearningActivity> activitiesForSource(String slug) =>
      _bySource[slug] ?? const [];
  static Future<LearningActivityCatalog>? _future;
  static Future<LearningActivityCatalog> load() =>
      _future ??= _load().catchError((Object error) {
        _future = null;
        throw error;
      });
  static Future<LearningActivityCatalog> _load() async {
    final files = await Future.wait([
      rootBundle.loadString('assets/data/learning_activities.json'),
      rootBundle.loadString('assets/data/vocab.json'),
      rootBundle.loadString('assets/audios/interlingua/manifest.json'),
    ]);
    final data = jsonDecode(files[0]) as Map<String, dynamic>;
    final vocab = jsonDecode(files[1]) as Map<String, dynamic>;
    final manifest = jsonDecode(files[2]) as Map<String, dynamic>;
    final audioNames = (manifest['entries'] as List)
        .map((item) => item['filename'] as String)
        .toSet();
    final activities = <LearningActivity>[
      for (final item in data['cloze'] as List)
        LearningActivity(
          id: item['id'] as String,
          sourceSlug: item['sourceSlug'] as String,
          mode: PracticeMode.cloze,
          prompt: item['prompt'] as String,
          sourceText: item['sourceText'] as String,
          answers: List<String>.from(item['answers'] as List),
          explanation: item['explanation'] as String,
        ),
    ];
    for (final entry in vocab.entries) {
      if (entry.key == 'extra') continue;
      final seen = <String>{};
      for (final item in entry.value as List) {
        final term = item['term'] as String;
        final key = OptionAudioService.normalizeOptionText(term);
        if (!seen.add(key) || !audioNames.contains('$key.wav')) continue;
        activities.add(
          LearningActivity(
            id: '${entry.key}-dictation-$key',
            sourceSlug: entry.key,
            mode: PracticeMode.dictation,
            prompt: 'Ascolta e scribe in Interlingua.',
            answers: [term],
            explanation: 'Compara tu responsa con le texto del audio.',
            audioAsset: 'assets/audios/interlingua/$key.wav',
          ),
        );
      }
    }
    return LearningActivityCatalog(
      List.unmodifiable(activities),
      termsBySource: {
        for (final entry in vocab.entries)
          if (entry.key != 'extra')
            entry.key: [
              for (final item in entry.value as List) item['term'] as String,
            ],
      },
    );
  }

  // Callers sort this result for review priority; do not expose the index list.
  List<LearningActivity> forSource(String slug, PracticeMode mode) =>
      List.of(_byMode[(slug, mode)] ?? const <LearningActivity>[]);
}
