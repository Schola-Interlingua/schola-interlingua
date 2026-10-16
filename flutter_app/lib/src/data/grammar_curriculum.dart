import 'grammar_lessons.dart';

const grammarTopicIdsByLevel = <String, List<String>>{
  'nivel-1': ["articulos", "plural", "presente"],
  'nivel-2': ["adjectivos", "comparation", "pronomines"],
  'nivel-3': ["possessivos", "questiones", "infinitivo"],
  'nivel-4': ["demonstrativos", "conjunctiones", "adverbios"],
  'nivel-5': ["tempores", "perfecte", "imperativo"],
  'nivel-6': ["negation", "relativos", "passivo"],
};

GrammarLesson? grammarLessonForSlug(String slug) {
  for (final lesson in grammarLessons) {
    if (slug == 'grammatica-${lesson.id}') return lesson;
  }
  return null;
}

List<GrammarLesson> grammarForLevel(String slug) => [
  for (final id in grammarTopicIdsByLevel[slug] ?? <String>[])
    grammarLessons.firstWhere((lesson) => lesson.id == id),
];
