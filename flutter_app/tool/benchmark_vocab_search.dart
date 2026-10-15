// Run from flutter_app with: dart run tool/benchmark_vocab_search.dart
import 'dart:convert';
import 'dart:io';
import 'package:schola_interlingua_flutter/src/services/vocab_search_index.dart';

void main() {
  final data =
      jsonDecode(File('assets/data/vocab.json').readAsStringSync())
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
  const queries = ['a', 'le', 'par', 'hablar', 'casa', 'to speak', 'zzzzzz'];
  final build = Stopwatch()..start();
  final index = VocabSearchIndex(items, 'es');
  build.stop();
  for (var i = 0; i < 10; i++) {
    for (final query in queries) {
      legacySearch(items, 'es', query);
      index.search(query);
    }
  }
  var checksum = 0;
  final before = Stopwatch()..start();
  for (var i = 0; i < 100; i++) {
    for (final query in queries) {
      checksum += legacySearch(items, 'es', query).take(8).length;
    }
  }
  before.stop();
  final after = Stopwatch()..start();
  for (var i = 0; i < 100; i++) {
    for (final query in queries) {
      checksum -= index.search(query).length;
    }
  }
  after.stop();
  if (checksum != 0) throw StateError('Result counts differ');
  stdout.writeln('Items: ${items.length}; queries: ${queries.length * 100}');
  stdout.writeln('Index construction: ${build.elapsedMicroseconds} us');
  stdout.writeln('Legacy: ${before.elapsedMicroseconds} us');
  stdout.writeln('Indexed: ${after.elapsedMicroseconds} us');
  stdout.writeln(
    'Speedup: ${(before.elapsedMicroseconds / after.elapsedMicroseconds).toStringAsFixed(1)}x',
  );
}

// Baseline from the original home-screen implementation.
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
