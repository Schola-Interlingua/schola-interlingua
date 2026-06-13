import 'dart:collection';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/course_seed.dart';
import 'models/course_models.dart';

class AppController extends ChangeNotifier {
  static const int _completionStorageVersion = 2;
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
  User? _currentUser;
  StreamSubscription<AuthState>? _authSubscription;

  String get selectedLanguage => _selectedLanguage;
  bool get vocabLoaded => _vocabLoaded;
  bool get darkMode => _darkMode;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  List<Map<String, String>> get allVocabItems => _lessonItems.values
      .expand((List<Map<String, String>> items) => items)
      .toList();
  Set<String> get completedKeys =>
      UnmodifiableSetView<String>(_completedItems.keys.toSet());
  int get consecutiveDaysStreak {
    final Set<DateTime> completionDays = _completedItems.values
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .map((DateTime value) {
          final DateTime local = value.toLocal();
          return DateTime(local.year, local.month, local.day);
        })
        .toSet();

    if (completionDays.isEmpty) return 0;

    DateTime current = _today();
    int streak = 0;

    while (completionDays.contains(current)) {
      streak += 1;
      current = current.subtract(const Duration(days: 1));
    }

    return streak;
  }

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
    _currentUser = Supabase.instance.client.auth.currentUser;
    _prefs = await SharedPreferences.getInstance();
    _selectedLanguage =
        _prefs?.getString('selected_language') ?? _selectedLanguage;
    _darkMode = _prefs?.getBool('dark_mode') ?? false;
    final int storedCompletionVersion =
        _prefs?.getInt('completion_storage_version') ?? 0;
    if (storedCompletionVersion < _completionStorageVersion) {
      _completedItems.clear();
      await _prefs?.remove('completed_items');
      await _prefs?.setInt(
        'completion_storage_version',
        _completionStorageVersion,
      );
      return;
    }
    final String? rawCompleted = _prefs?.getString('completed_items');
    if (rawCompleted != null && rawCompleted.isNotEmpty) {
      final Map<String, dynamic> decoded =
          jsonDecode(rawCompleted) as Map<String, dynamic>;
      _completedItems
        ..clear()
        ..addAll(
          decoded.map(
            (String key, dynamic value) => MapEntry(key, value.toString()),
          ),
        );
    }

    if (_currentUser != null) {
      await _loadProgressFromRemote();
    }

    _authSubscription?.cancel();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      AuthState data,
    ) {
      unawaited(_handleAuthStateChange(data.session?.user));
    });
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
    _persistCompletedItems();
    unawaited(_syncProgressToRemote());
    notifyListeners();
  }

  void clearCompleted(String key) {
    if (_completedItems.remove(key) == null) return;
    _persistCompletedItems();
    unawaited(_syncProgressToRemote());
    notifyListeners();
  }

  bool isCompleted(String key) => _completedItems.containsKey(key);

  String? completionDate(String key) => _completedItems[key];

  Future<void> signInWithEmail(
    String email, {
    required String redirectTo,
  }) async {
    await Supabase.instance.client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: redirectTo,
    );
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  static String normalizeTerm(String input) {
    return input
        .replaceAll(RegExp(r'[^\wáéíóúüñ-]', unicode: true), '')
        .toLowerCase();
  }

  DateTime _today() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _handleAuthStateChange(User? nextUser) async {
    final String? previousId = _currentUser?.id;
    final String? nextId = nextUser?.id;
    _currentUser = nextUser;

    if (previousId != nextId && nextUser != null) {
      await _loadProgressFromRemote();
    }

    notifyListeners();
  }

  Future<void> _loadProgressFromRemote() async {
    if (_currentUser == null) return;

    final PostgrestMap? row = await Supabase.instance.client
        .from('progress')
        .select('data')
        .eq('user_id', _currentUser!.id)
        .maybeSingle();

    final Map<String, dynamic> progress =
        (row?['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final Map<String, dynamic> lessons =
        (progress['lessons'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    final Map<String, String> merged = Map<String, String>.from(
      _completedItems,
    );
    lessons.forEach((String slug, dynamic value) {
      if (value is! Map) return;
      if (value['completed'] != true) return;
      final String key = _completionKeyFromSlug(slug);
      final String remoteValue = value['last_done']?.toString() ?? _todayIso();
      final String? currentValue = merged[key];
      if (currentValue == null || remoteValue.compareTo(currentValue) >= 0) {
        merged[key] = remoteValue;
      }
    });
    _completedItems
      ..clear()
      ..addAll(merged);
    _persistCompletedItems();
    await _syncProgressToRemote();
  }

  Future<void> _syncProgressToRemote() async {
    if (_currentUser == null) return;

    final Map<String, dynamic> lessons = <String, dynamic>{};
    _completedItems.forEach((String key, String value) {
      lessons[_slugFromCompletionKey(key)] = <String, dynamic>{
        'completed': true,
        'last_done': _dateOnly(value),
      };
    });

    final List<String> sortedDates =
        _completedItems.values.map(_dateOnly).toList()..sort();

    await Supabase.instance.client.from('progress').upsert(<String, dynamic>{
      'user_id': _currentUser!.id,
      'data': <String, dynamic>{
        'lessons': lessons,
        'streak': <String, dynamic>{
          'current': consecutiveDaysStreak,
          'best': consecutiveDaysStreak,
          'last_study_date': sortedDates.isEmpty ? null : sortedDates.last,
        },
      },
    }, onConflict: 'user_id');
  }

  void _persistCompletedItems() {
    _prefs?.setInt('completion_storage_version', _completionStorageVersion);
    _prefs?.setString('completed_items', jsonEncode(_completedItems));
  }

  String _todayIso() => _today().toIso8601String();

  String _dateOnly(String isoDate) {
    final DateTime parsed =
        DateTime.tryParse(isoDate)?.toLocal() ?? DateTime.now();
    final String month = parsed.month.toString().padLeft(2, '0');
    final String day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }

  String _slugFromCompletionKey(String key) => key.split(':').last;

  String _completionKeyFromSlug(String slug) {
    for (final CourseLevel level in courseLevels) {
      for (final CourseSection section in level.sections) {
        for (final CourseItemRef item in section.items) {
          if (item.slug != slug) continue;
          switch (item.kind) {
            case CourseItemKind.lesson:
            case CourseItemKind.vocabulary:
              return 'lesson:$slug';
            case CourseItemKind.reading:
              return 'reading:$slug';
            case CourseItemKind.appendix:
              return 'appendix:$slug';
          }
        }
      }
    }
    return 'lesson:$slug';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
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
