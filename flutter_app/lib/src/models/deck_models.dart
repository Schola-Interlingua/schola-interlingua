class VocabularyWord {
  const VocabularyWord({
    required this.id,
    required this.term,
    required this.translations,
  });

  final String id;
  final String term;
  final Map<String, String> translations;
}

class CustomDeck {
  const CustomDeck({
    required this.id,
    required this.name,
    required this.wordIds,
    required this.createdAt,
  });

  factory CustomDeck.fromJson(Map<String, dynamic> json) {
    final List<String> wordIds =
        (json['wordIds'] as List<dynamic>? ?? const <dynamic>[])
            .map((dynamic value) => value.toString())
            .where((String value) => value.trim().isNotEmpty)
            .toSet()
            .toList();

    return CustomDeck(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      wordIds: wordIds,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String id;
  final String name;
  final List<String> wordIds;
  final DateTime createdAt;

  CustomDeck copyWith({String? name, List<String>? wordIds}) {
    return CustomDeck(
      id: id,
      name: name ?? this.name,
      wordIds: wordIds ?? this.wordIds,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'wordIds': wordIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
