import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

const String _ankiDeckBucket = 'anki-decks';
const String _manifestObjectPath = 'anki/manifest.json';
const String _fallbackManifestAsset = 'assets/data/anki_manifest.json';

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
    required this.objectPath,
    required this.publicUrl,
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
      objectPath:
          json['objectPath'] as String? ?? json['file'] as String? ?? '',
      publicUrl: json['publicUrl'] as String? ?? '',
      noteCount: (json['noteCount'] as num?)?.toInt() ?? 0,
      levelCount: (json['levelCount'] as num?)?.toInt() ?? 0,
      sourceCount: (json['sourceCount'] as num?)?.toInt() ?? 0,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
    );
  }

  final String language;
  final String label;
  final String file;
  final String objectPath;
  final String publicUrl;
  final int noteCount;
  final int levelCount;
  final int sourceCount;
  final int sizeBytes;

  String get downloadUrl {
    if (publicUrl.isNotEmpty) return publicUrl;
    final String path = objectPath.isNotEmpty ? objectPath : file;
    return Supabase.instance.client.storage
        .from(_ankiDeckBucket)
        .getPublicUrl(path);
  }
}

Future<AnkiExportManifest> loadAnkiExportManifest() async {
  try {
    final String manifestUrl = Supabase.instance.client.storage
        .from(_ankiDeckBucket)
        .getPublicUrl(_manifestObjectPath);
    final http.Response response = await http.get(Uri.parse(manifestUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      return AnkiExportManifest.fromJson(json);
    }
    throw StateError(
      'Supabase manifest request failed with ${response.statusCode}.',
    );
  } catch (_) {
    final String raw = await rootBundle.loadString(_fallbackManifestAsset);
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
    return AnkiExportManifest.fromJson(json);
  }
}
