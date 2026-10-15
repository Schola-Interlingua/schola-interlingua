import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schola_interlingua_flutter/src/services/vocab_search_index.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'indexed search preserves existing multilingual ranking and deduplication',
    () async {
      final data =
          jsonDecode(await rootBundle.loadString('assets/data/vocab.json'))
              as Map<String, dynamic>;
      final items = data.values
          .whereType<List>()
          .expand((list) => list)
          .whereType<Map>()
          .map(
            (item) => item.map(
              (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
            ),
          )
          .toList();
      for (final language in [
        'es',
        'en',
        'pt',
        'de',
        'fr',
        'it',
        'ru',
        'zh',
        'ja',
        'ko',
        'ca',
        'la',
        'eo',
        'unknown',
      ]) {
        final index = VocabSearchIndex(items, language);
        for (final query in [
          'a',
          'le',
          'par',
          'hablar',
          'ÁRBOL',
          'casa',
          'un ',
          'ñ',
          'to speak',
          '.',
          '中文',
          'zzzzzz',
        ]) {
          final expected = legacySearch(
            items,
            language,
            query,
          ).take(8).map((r) => '${r.term}|${r.translation}').toList();
          final actual = index
              .search(query)
              .map((r) => '${r.term}|${r.translation}')
              .toList();
          expect(actual, expected, reason: '$language: $query');
        }
      }
    },
  );
  test('empty queries, limits, fallback and repeated searches', () {
    final index = VocabSearchIndex([
      {'term': 'casa', 'es': 'hogar'},
      {'term': 'casa', 'es': 'hogar'},
      {'term': 'casamento', 'es': 'boda', 'en': ''},
      {'term': 'acas', 'es': 'casa'},
    ], 'en');
    expect(index.search('  '), isEmpty);
    expect(index.search('ca', limit: 0), isEmpty);
    expect(index.search('ca', limit: 1).single.term, 'acas');
    expect(index.search('ca').map((r) => r.term), ['acas', 'casa']);
    expect(identical(index.search('ca'), index.search('ca')), isTrue);
  });
}

List<VocabSearchResult> legacySearch(
  List<Map<String, String>> items,
  String language,
  String query,
) {
  final String normalizedQuery = _normalizeSearch(query);
  final Map<String, VocabSearchResult> unique = <String, VocabSearchResult>{};

  for (final Map<String, String> item in items) {
    final String term = (item['term'] ?? '').trim();
    if (term.isEmpty) continue;
    final String translation = (item[language] ?? item['es'] ?? '').trim();
    if (translation.isEmpty) continue;

    final bool matchesTerm = _normalizeSearch(term).contains(normalizedQuery);
    final bool matchesTranslation = _normalizeSearch(
      translation,
    ).contains(normalizedQuery);
    if (!matchesTerm && !matchesTranslation) continue;

    final VocabSearchResult result = VocabSearchResult(
      term: term,
      translation: translation,
    );
    final String key = '${term.toLowerCase()}|${translation.toLowerCase()}';
    unique.putIfAbsent(key, () => result);
  }

  final List<VocabSearchResult> results = unique.values.toList();
  results.sort((VocabSearchResult a, VocabSearchResult b) {
    final bool aStarts =
        _normalizeSearch(a.term).startsWith(normalizedQuery) ||
        _normalizeSearch(a.translation).startsWith(normalizedQuery);
    final bool bStarts =
        _normalizeSearch(b.term).startsWith(normalizedQuery) ||
        _normalizeSearch(b.translation).startsWith(normalizedQuery);
    if (aStarts != bStarts) return aStarts ? -1 : 1;
    return a.term.compareTo(b.term);
  });
  return results;
}

String _normalizeSearch(String value) {
  return value
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^\w\s]', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
