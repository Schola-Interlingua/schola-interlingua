import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/learning_practice.dart';
import 'option_audio_service.dart';

class LearningActivityCatalog {
  LearningActivityCatalog(this.activities);
  final List<LearningActivity> activities;
  static Future<LearningActivityCatalog>? _future;
  static Future<LearningActivityCatalog> load() =>
      _future ??= _load().catchError((Object error) {
        _future = null;
        throw error;
      });
  static Future<LearningActivityCatalog> _load() async {
    final data =
        jsonDecode(
              await rootBundle.loadString(
                'assets/data/learning_activities.json',
              ),
            )
            as Map<String, dynamic>;
    final vocab =
        jsonDecode(await rootBundle.loadString('assets/data/vocab.json'))
            as Map<String, dynamic>;
    final manifest =
        jsonDecode(
              await rootBundle.loadString(
                'assets/audios/interlingua/manifest.json',
              ),
            )
            as Map<String, dynamic>;
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
    return LearningActivityCatalog(List.unmodifiable(activities));
  }

  List<LearningActivity> forSource(String slug, PracticeMode mode) => activities
      .where((activity) => activity.sourceSlug == slug && activity.mode == mode)
      .toList();
}
