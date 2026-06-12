import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/web_content_models.dart';

class WebContentLoader {
  static Map<String, dynamic>? _content;

  static Future<ParsedLectionContent?> loadLection(String slug) async {
    try {
      final Map<String, dynamic> data = await _loadContent();
      final Map<String, dynamic>? item =
          (data['lections'] as Map<String, dynamic>?)?[slug]
              as Map<String, dynamic>?;
      if (item == null) return null;

      return ParsedLectionContent(
        title: item['title'] as String? ?? slug,
        audioAsset: item['audioAsset'] as String?,
        paragraphs: _stringList(item['paragraphs']),
        imageAsset: item['imageAsset'] as String?,
        grammarBullets: _stringList(item['grammarBullets']),
      );
    } catch (error, stackTrace) {
      throw StateError('loadLection($slug): $error\n$stackTrace');
    }
  }

  static Future<ParsedReadingContent?> loadReading(String slug) async {
    try {
      final Map<String, dynamic> data = await _loadContent();
      final Map<String, dynamic>? item =
          (data['readings'] as Map<String, dynamic>?)?[slug]
              as Map<String, dynamic>?;
      if (item == null) return null;

      return ParsedReadingContent(
        title: item['title'] as String? ?? slug,
        paragraphs: _stringList(item['paragraphs']),
        imageAsset: item['imageAsset'] as String?,
      );
    } catch (error, stackTrace) {
      throw StateError('loadReading($slug): $error\n$stackTrace');
    }
  }

  static Future<ParsedAppendixContent?> loadAppendix(String slug) async {
    try {
      final Map<String, dynamic> data = await _loadContent();
      final Map<String, dynamic>? item =
          (data['appendices'] as Map<String, dynamic>?)?[slug]
              as Map<String, dynamic>?;
      if (item == null) return null;

      final List<ParsedAppendixSection> sections = (item['sections'] as List?)
              ?.whereType<Map>()
              .map(
                (Map section) => ParsedAppendixSection(
                  title: section['title']?.toString() ?? '',
                  paragraphs: _stringList(section['paragraphs']),
                  bullets: _stringList(section['bullets']),
                ),
              )
              .toList() ??
          const <ParsedAppendixSection>[];

      return ParsedAppendixContent(
        title: item['title'] as String? ?? slug,
        sections: sections,
      );
    } catch (error, stackTrace) {
      throw StateError('loadAppendix($slug): $error\n$stackTrace');
    }
  }

  static Future<Map<String, dynamic>> _loadContent() async {
    try {
      if (_content != null) return _content!;
      final String raw = await rootBundle.loadString('assets/data/content.json');
      _content = jsonDecode(raw) as Map<String, dynamic>;
      return _content!;
    } catch (error, stackTrace) {
      throw StateError('loadContent: $error\n$stackTrace');
    }
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value.map((dynamic item) => item.toString()).toList();
  }
}
