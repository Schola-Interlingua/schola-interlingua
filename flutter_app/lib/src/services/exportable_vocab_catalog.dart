import '../data/course_seed.dart';
import '../models/course_models.dart';

class ExportableVocabCard {
  const ExportableVocabCard({
    required this.id,
    required this.term,
    required this.translations,
    required this.levelSlug,
    required this.levelTitle,
    required this.sourceSlug,
    required this.sourceTitle,
  });

  final String id;
  final String term;
  final Map<String, String> translations;
  final String levelSlug;
  final String levelTitle;
  final String sourceSlug;
  final String sourceTitle;
}

List<ExportableVocabCard> buildExportableVocabCatalog(
  Map<String, List<Map<String, String>>> lessonItems,
) {
  final Map<String, ExportableVocabCard> cards =
      <String, ExportableVocabCard>{};

  for (final CourseLevel level in courseLevels) {
    for (final CourseSection section in level.sections) {
      for (final CourseItemRef item in section.items) {
        if (item.kind != CourseItemKind.vocabulary) continue;
        final List<Map<String, String>> vocabItems =
            lessonItems[item.slug] ?? const <Map<String, String>>[];
        for (final Map<String, String> vocabItem in vocabItems) {
          final String term = (vocabItem['term'] ?? '').trim();
          if (term.isEmpty) continue;
          final Map<String, String> translations = <String, String>{};
          vocabItem.forEach((String key, String value) {
            if (key == 'term' || value.trim().isEmpty) return;
            translations[key] = value.trim();
          });
          final String id = '${item.slug}:${term.toLowerCase()}';
          cards[id] = ExportableVocabCard(
            id: id,
            term: term,
            translations: translations,
            levelSlug: level.slug,
            levelTitle: level.title,
            sourceSlug: item.slug,
            sourceTitle: item.title,
          );
        }
      }
    }
  }

  final List<ExportableVocabCard> sorted = cards.values.toList()
    ..sort((ExportableVocabCard a, ExportableVocabCard b) {
      final int byLevel = a.levelTitle.compareTo(b.levelTitle);
      if (byLevel != 0) return byLevel;
      final int bySource = a.sourceTitle.compareTo(b.sourceTitle);
      if (bySource != 0) return bySource;
      return a.term.compareTo(b.term);
    });
  return sorted;
}
