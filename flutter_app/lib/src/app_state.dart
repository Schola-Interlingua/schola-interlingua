import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends ChangeNotifier {
  static const Map<String, Map<String, String>> _glossaryOverrides =
      <String, Map<String, String>>{
        'definite': <String, String>{
          'es': 'definido',
          'en': 'definite',
          'pt': 'definido',
          'it': 'definito',
          'fr': 'défini',
          'de': 'definit',
          'ca': 'definit',
        },
        'indefinite': <String, String>{
          'es': 'indefinido',
          'en': 'indefinite',
          'pt': 'indefinido',
          'it': 'indefinito',
          'fr': 'indéfini',
          'de': 'unbestimmt',
          'ca': 'indefinit',
        },
        'pronomines': <String, String>{
          'es': 'pronombres',
          'en': 'pronouns',
          'pt': 'pronomes',
          'it': 'pronomi',
          'fr': 'pronoms',
          'de': 'Pronomen',
          'ca': 'pronoms',
        },
        'variationes': <String, String>{
          'es': 'variaciones',
          'en': 'variations',
          'pt': 'variações',
          'it': 'variazioni',
          'fr': 'variations',
          'de': 'Variationen',
          'ca': 'variacions',
        },
        'verbo': <String, String>{
          'es': 'verbo',
          'en': 'verb',
          'pt': 'verbo',
          'it': 'verbo',
          'fr': 'verbe',
          'de': 'Verb',
          'ca': 'verb',
        },
        'verbos': <String, String>{
          'es': 'verbos',
          'en': 'verbs',
          'pt': 'verbos',
          'it': 'verbi',
          'fr': 'verbes',
          'de': 'Verben',
          'ca': 'verbs',
        },
        'presente': <String, String>{
          'es': 'presente',
          'en': 'present',
          'pt': 'presente',
          'it': 'presente',
          'fr': 'présent',
          'de': 'Präsens',
          'ca': 'present',
        },
      };

  String _selectedLanguage = 'es';
  Map<String, Map<String, String>> _vocab = <String, Map<String, String>>{};
  final Map<String, List<Map<String, String>>> _lessonItems =
      <String, List<Map<String, String>>>{};
  bool _vocabLoaded = false;
  bool _darkMode = false;
  SharedPreferences? _prefs;
  final Map<String, String> _completedItems = <String, String>{};

  String get selectedLanguage => _selectedLanguage;
  bool get vocabLoaded => _vocabLoaded;
  bool get darkMode => _darkMode;
  List<Map<String, String>> get allVocabItems =>
      _lessonItems.values.expand((List<Map<String, String>> items) => items).toList();

  Map<String, String>? lookupMeaning(String term) =>
      _vocab[normalizeTerm(term)];
  String? resolveMeaning(String term, String language) {
    final String normalized = normalizeTerm(term);
    final Map<String, String>? override = _glossaryOverrides[normalized];
    final Map<String, String>? meaning = _vocab[normalized];

    String? pick(Map<String, String>? source, String key) {
      final String? value = source?[key]?.trim();
      return value == null || value.isEmpty ? null : value;
    }

    final List<String> fallbackOrder = <String>[
      language,
      'es',
      'en',
      'pt',
      'it',
      'fr',
      'de',
      'ca',
      'ru',
      'zh',
      'ja',
      'ko',
    ];

    for (final String key in fallbackOrder) {
      final String? overrideValue = pick(override, key);
      if (overrideValue != null) return overrideValue;
      final String? vocabValue = pick(meaning, key);
      if (vocabValue != null) return vocabValue;
    }

    return null;
  }
  List<Map<String, String>> lessonItems(String slug) =>
      _lessonItems[slug] ?? const <Map<String, String>>[];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _selectedLanguage = _prefs?.getString('selected_language') ?? _selectedLanguage;
    _darkMode = _prefs?.getBool('dark_mode') ?? false;
    final String? rawCompleted = _prefs?.getString('completed_items');
    if (rawCompleted != null && rawCompleted.isNotEmpty) {
      final Map<String, dynamic> decoded =
          jsonDecode(rawCompleted) as Map<String, dynamic>;
      _completedItems
        ..clear()
        ..addAll(decoded.map(
          (String key, dynamic value) => MapEntry(key, value.toString()),
        ));
    }
  }

  Future<void> loadVocab() async {
    if (_vocabLoaded) return;
    final String raw = await rootBundle.loadString('assets/data/vocab.json');
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    final Map<String, Map<String, String>> parsed =
        <String, Map<String, String>>{};

    for (final MapEntry<String, dynamic> entry in data.entries) {
      final dynamic value = entry.value;
      if (value is! List<dynamic>) continue;
      final List<Map<String, String>> lessonList = <Map<String, String>>[];
      for (final dynamic item in value) {
        if (item is! Map<String, dynamic>) continue;
        final String term = normalizeTerm(item['term'] as String? ?? '');
        if (term.isEmpty) continue;
        final Map<String, String> translations = <String, String>{};
        item.forEach((key, value) {
          if (key == 'term' || value == null) return;
          translations[key] = value.toString();
        });
        parsed[term] = translations;
        lessonList.add(
          item.map(
            (dynamic key, dynamic value) =>
                MapEntry(key.toString(), value?.toString() ?? ''),
          ),
        );
      }
      _lessonItems[entry.key] = lessonList;
    }

    _vocab = parsed;
    _vocabLoaded = true;
    notifyListeners();
  }

  void setSelectedLanguage(String language) {
    if (_selectedLanguage == language) return;
    _selectedLanguage = language;
    _prefs?.setString('selected_language', language);
    notifyListeners();
  }

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    _prefs?.setBool('dark_mode', _darkMode);
    notifyListeners();
  }

  void markCompleted(String key) {
    final String timestamp = DateTime.now().toIso8601String();
    _completedItems[key] = timestamp;
    _prefs?.setString('completed_items', jsonEncode(_completedItems));
    notifyListeners();
  }

  bool isCompleted(String key) => _completedItems.containsKey(key);

  String? completionDate(String key) => _completedItems[key];

  static String normalizeTerm(String input) {
    return input
        .replaceAll(RegExp(r'[^\wáéíóúüñ-]', unicode: true), '')
        .toLowerCase();
  }
}

class AppStateScope extends InheritedNotifier<AppController> {
  const AppStateScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final AppStateScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in context');
    return scope!.notifier!;
  }
}
