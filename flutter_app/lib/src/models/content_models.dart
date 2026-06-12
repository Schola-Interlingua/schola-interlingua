class ReadingContent {
  const ReadingContent({
    required this.slug,
    required this.title,
    required this.paragraphs,
    required this.imageAsset,
  });

  final String slug;
  final String title;
  final List<String> paragraphs;
  final String imageAsset;
}

class AppendixContent {
  const AppendixContent({
    required this.slug,
    required this.title,
    required this.sections,
  });

  final String slug;
  final String title;
  final List<AppendixSection> sections;
}

class AppendixSection {
  const AppendixSection({
    required this.title,
    required this.paragraphs,
    this.bullets = const <String>[],
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}

class VocabMeaning {
  const VocabMeaning({required this.term, required this.meanings});

  final String term;
  final Map<String, String> meanings;
}
