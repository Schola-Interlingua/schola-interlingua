import 'dart:convert';

import 'package:flutter/services.dart';

class AnkiExportManifest {
  const AnkiExportManifest({
    required this.deckName,
    required this.structure,
    required this.languages,
  });

  factory AnkiExportManifest.fromJson(Map<String, dynamic> json) {
    final Map<String, AnkiDeckAsset> languages = <String, AnkiDeckAsset>{};
    final dynamic rawLanguages = json['languages'];
    if (rawLanguages is Map<String, dynamic>) {
      rawLanguages.forEach((String language, dynamic value) {
        if (value is Map<String, dynamic>) {
          languages[language] = AnkiDeckAsset.fromJson(value);
        }
      });
    }
    return AnkiExportManifest(
      deckName: json['deckName'] as String? ?? 'Schola Interlingua',
      structure: json['structure'] as String? ?? 'level-source',
      languages: languages,
    );
  }

  final String deckName;
  final String structure;
  final Map<String, AnkiDeckAsset> languages;

  AnkiDeckAsset? deckForLanguage(String language) => languages[language];
}

class AnkiDeckAsset {
  const AnkiDeckAsset({
    required this.language,
    required this.label,
    required this.file,
    required this.assetPath,
    required this.noteCount,
    required this.levelCount,
    required this.sourceCount,
    required this.sizeBytes,
  });

  factory AnkiDeckAsset.fromJson(Map<String, dynamic> json) {
    return AnkiDeckAsset(
      language: json['language'] as String? ?? '',
      label: json['label'] as String? ?? '',
      file: json['file'] as String? ?? '',
      assetPath: json['assetPath'] as String? ?? '',
      noteCount: (json['noteCount'] as num?)?.toInt() ?? 0,
      levelCount: (json['levelCount'] as num?)?.toInt() ?? 0,
      sourceCount: (json['sourceCount'] as num?)?.toInt() ?? 0,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
    );
  }

  final String language;
  final String label;
  final String file;
  final String assetPath;
  final int noteCount;
  final int levelCount;
  final int sourceCount;
  final int sizeBytes;
}

Future<AnkiExportManifest> loadAnkiExportManifest() async {
  final String raw = await rootBundle.loadString('assets/apkg/manifest.json');
  final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
  return AnkiExportManifest.fromJson(json);
}
