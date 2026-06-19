class ParsedLectionContent {
  const ParsedLectionContent({
    required this.title,
    required this.audioAsset,
    required this.paragraphs,
    required this.imageAsset,
    required this.grammarBullets,
  });

  final String title;
  final String? audioAsset;
  final List<String> paragraphs;
  final String? imageAsset;
  final List<String> grammarBullets;
}

class ParsedReadingContent {
  const ParsedReadingContent({
    required this.title,
    required this.paragraphs,
    required this.imageAsset,
  });

  final String title;
  final List<String> paragraphs;
  final String? imageAsset;
}

class ParsedAppendixContent {
  const ParsedAppendixContent({required this.title, required this.sections});

  final String title;
  final List<ParsedAppendixSection> sections;
}

class ParsedAppendixSection {
  const ParsedAppendixSection({
    required this.title,
    required this.paragraphs,
    required this.bullets,
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}
