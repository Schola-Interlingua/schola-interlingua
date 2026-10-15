class VocabSearchResult {
  const VocabSearchResult({required this.term, required this.translation});

  final String term;
  final String translation;
}

/// A language-specific snapshot. Normalize once, not per keystroke.
class VocabSearchIndex {
  VocabSearchIndex(List<Map<String, String>> items, String language) {
    final unique = <String, _SearchEntry>{};
    for (final item in items) {
      final term = (item['term'] ?? '').trim();
      final translation = (item[language] ?? item['es'] ?? '').trim();
      if (term.isEmpty || translation.isEmpty) continue;
      final key = '${term.toLowerCase()}|${translation.toLowerCase()}';
      unique.putIfAbsent(
        key,
        () => _SearchEntry(
          VocabSearchResult(term: term, translation: translation),
        ),
      );
    }
    _entries = unique.values.toList();
  }

  late final List<_SearchEntry> _entries;
  String? _lastQuery;
  int? _lastLimit;
  List<VocabSearchResult> _lastResults = const [];

  List<VocabSearchResult> search(String query, {int limit = 8}) {
    if (query.trim().isEmpty || limit <= 0) return const [];
    final normalized = _normalizeSearch(query);
    if (_lastQuery == normalized && _lastLimit == limit) return _lastResults;

    final matches = _entries
        .where(
          (entry) =>
              entry.term.contains(normalized) ||
              entry.translation.contains(normalized),
        )
        .toList();
    // Keep the original comparator and input order, including equal-term ties.
    matches.sort((a, b) {
      final aStarts =
          a.term.startsWith(normalized) || a.translation.startsWith(normalized);
      final bStarts =
          b.term.startsWith(normalized) || b.translation.startsWith(normalized);
      if (aStarts != bStarts) return aStarts ? -1 : 1;
      return a.result.term.compareTo(b.result.term);
    });
    _lastQuery = normalized;
    _lastLimit = limit;
    return _lastResults = List.unmodifiable(
      matches.take(limit).map((entry) => entry.result),
    );
  }
}

class _SearchEntry {
  _SearchEntry(this.result)
    : term = _normalizeSearch(result.term),
      translation = _normalizeSearch(result.translation);

  final VocabSearchResult result;
  final String term;
  final String translation;
}

final _punctuation = RegExp(r'[^\w\s]', unicode: true);
final _whitespace = RegExp(r'\s+');

String _normalizeSearch(String value) => value
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ü', 'u')
    .replaceAll('ñ', 'n')
    .replaceAll(_punctuation, ' ')
    .replaceAll(_whitespace, ' ')
    .trim();
