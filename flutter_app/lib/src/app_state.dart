import 'dart:collection';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/course_seed.dart';
import 'models/course_models.dart';
import 'models/srs_models.dart';
import 'services/exportable_vocab_catalog.dart';

class AppController extends ChangeNotifier {
  static const int _completionStorageVersion = 3;
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
  final Map<String, ExportableVocabCard> _exportableCardsById =
      <String, ExportableVocabCard>{};
  final Map<String, List<ExportableVocabCard>> _exportableCardsBySlug =
      <String, List<ExportableVocabCard>>{};
  final Map<String, SrsCardProgress> _srsProgress = <String, SrsCardProgress>{};
  bool _vocabLoaded = false;
  bool _darkMode = true;
  SharedPreferences? _prefs;
  final Map<String, String> _completedItems = <String, String>{};
  User? _currentUser;
  StreamSubscription<AuthState>? _authSubscription;

  String get selectedLanguage => _selectedLanguage;
  bool get vocabLoaded => _vocabLoaded;
  bool get darkMode => _darkMode;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  List<ExportableVocabCard> get exportableCards =>
      _exportableCardsById.values.toList()
        ..sort((ExportableVocabCard a, ExportableVocabCard b) {
          final int byLevel = a.levelTitle.compareTo(b.levelTitle);
          if (byLevel != 0) return byLevel;
          return a.term.compareTo(b.term);
        });
  List<Map<String, String>> get allVocabItems => _lessonItems.values
      .expand((List<Map<String, String>> items) => items)
      .toList();
  Set<String> get completedKeys =>
      UnmodifiableSetView<String>(_completedItems.keys.toSet());
  Map<SrsStage, int> get srsStageCounts {
    final Map<SrsStage, int> counts = <SrsStage, int>{
      for (final SrsStage stage in SrsStage.values) stage: 0,
    };
    for (final SrsCardProgress progress in _srsProgress.values) {
      counts[progress.stage] = (counts[progress.stage] ?? 0) + 1;
    }
    return counts;
  }

  int get trackedSrsWordCount => _srsProgress.length;
  int get dueSrsWordCount =>
      _srsProgress.values.where((SrsCardProgress item) => item.isDue).length;
  List<SrsCardProgress> get dueSrsProgress =>
      _srsProgress.values.where((SrsCardProgress item) => item.isDue).toList()
        ..sort((SrsCardProgress a, SrsCardProgress b) {
          final int byDue = a.dueAt.compareTo(b.dueAt);
          if (byDue != 0) return byDue;
          return a.cardId.compareTo(b.cardId);
        });
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

  List<ExportableVocabCard> exportableCardsForSlug(String slug) =>
      _exportableCardsBySlug[slug] ?? const <ExportableVocabCard>[];
  ExportableVocabCard? exportableCardById(String cardId) =>
      _exportableCardsById[cardId];

  List<ExportableVocabCard> exportableCardsForLevels(Set<String> levelSlugs) {
    return exportableCards
        .where(
          (ExportableVocabCard card) => levelSlugs.contains(card.levelSlug),
        )
        .toList();
  }

  SrsCardProgress? srsProgressForCard(String cardId) => _srsProgress[cardId];

  SrsCardProgress? srsProgressForSlugTerm(String slug, String term) {
    return _srsProgress['$slug:${term.trim().toLowerCase()}'];
  }

  ExportableVocabCard? srsCardForSlugTerm(String slug, String term) {
    return _exportableCardsById['$slug:${term.trim().toLowerCase()}'];
  }

  Future<void> initialize() async {
    _currentUser = Supabase.instance.client.auth.currentUser;
    _prefs = await SharedPreferences.getInstance();
    _selectedLanguage =
        _prefs?.getString('selected_language') ?? _selectedLanguage;
    _darkMode = _prefs?.getBool('dark_mode') ?? true;
    final int storedCompletionVersion =
        _prefs?.getInt('completion_storage_version') ?? 0;
    if (storedCompletionVersion < _completionStorageVersion) {
      _completedItems.clear();
      _srsProgress.clear();
      await _prefs?.remove('completed_items');
      await _prefs?.remove('srs_progress');
      await _prefs?.setInt(
        'completion_storage_version',
        _completionStorageVersion,
      );
    }
    await _prefs?.remove('completed_items');
    await _prefs?.remove('srs_progress');
    _completedItems.clear();
    _srsProgress.clear();

    if (_currentUser != null) {
      await _loadProgressFromRemote(preferRemote: true);
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
    final List<ExportableVocabCard> catalog = buildExportableVocabCatalog(
      _lessonItems,
    );
    _exportableCardsById
      ..clear()
      ..addEntries(
        catalog.map(
          (ExportableVocabCard card) =>
              MapEntry<String, ExportableVocabCard>(card.id, card),
        ),
      );
    _exportableCardsBySlug
      ..clear()
      ..addEntries(
        catalog.fold<Map<String, List<ExportableVocabCard>>>(
          <String, List<ExportableVocabCard>>{},
          (
            Map<String, List<ExportableVocabCard>> grouped,
            ExportableVocabCard card,
          ) {
            grouped
                .putIfAbsent(card.sourceSlug, () => <ExportableVocabCard>[])
                .add(card);
            return grouped;
          },
        ).entries,
      );
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
    final String slug = _slugFromCompletionKey(key);
    if (_exportableCardsBySlug.containsKey(slug)) {
      registerVocabularySeen(slug);
    }
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

  void registerVocabularySeen(String slug) {
    final List<ExportableVocabCard> cards = exportableCardsForSlug(slug);
    if (cards.isEmpty) return;
    final DateTime now = DateTime.now();
    bool changed = false;
    for (final ExportableVocabCard card in cards) {
      if (_srsProgress.containsKey(card.id)) continue;
      _srsProgress[card.id] = SrsCardProgress(
        cardId: card.id,
        stage: SrsStage.newWord,
        intervalDays: 0,
        ease: 2.3,
        successCount: 0,
        failureCount: 0,
        dueAt: now,
        seenAt: now,
        updatedAt: now,
      );
      changed = true;
    }
    if (!changed) return;
    _persistSrsProgress();
    unawaited(_syncProgressToRemote());
    notifyListeners();
  }

  void recordSrsReview(String cardId, {required bool success}) {
    final ExportableVocabCard? card = _exportableCardsById[cardId];
    if (card == null) return;
    final DateTime now = DateTime.now();
    final SrsCardProgress current =
        _srsProgress[cardId] ??
        SrsCardProgress(
          cardId: cardId,
          stage: SrsStage.newWord,
          intervalDays: 0,
          ease: 2.3,
          successCount: 0,
          failureCount: 0,
          dueAt: now,
          seenAt: now,
          updatedAt: now,
        );
    final SrsCardProgress next = success
        ? _advanceSrsCard(current, now)
        : _resetSrsCard(current, now);
    _srsProgress[cardId] = next;
    _persistSrsProgress();
    unawaited(_syncProgressToRemote());
    notifyListeners();
  }

  void recordSrsReviewForSlugTerm(
    String slug,
    String term, {
    required bool success,
  }) {
    final ExportableVocabCard? card = srsCardForSlugTerm(slug, term);
    if (card == null) return;
    registerVocabularySeen(slug);
    recordSrsReview(card.id, success: success);
  }

  Future<void> signInWithEmailOtp(String email) async {
    await Supabase.instance.client.auth.signInWithOtp(email: email);
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    await Supabase.instance.client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
    _currentUser = Supabase.instance.client.auth.currentUser;
    await _loadProgressFromRemote(preferRemote: true);
    notifyListeners();
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future<void> deleteCurrentAccount() async {
    if (_currentUser == null) {
      throw StateError('No authenticated user');
    }

    final FunctionResponse response = await Supabase.instance.client.functions
        .invoke('delete-account', method: HttpMethod.post);

    if (response.status != 200) {
      final Object? data = response.data;
      final String message = data is Map && data['error'] != null
          ? data['error'].toString()
          : 'Delete account failed';
      throw Exception(message);
    }

    await Supabase.instance.client.auth.signOut();
    await _clearLocalUserData();
    _currentUser = null;
    notifyListeners();
  }

  static String normalizeTerm(String input) {
    return input
        .replaceAll(RegExp(r'[^\wáéíóúüñ-]', unicode: true), '')
        .toLowerCase();
  }

  SrsCardProgress _advanceSrsCard(SrsCardProgress current, DateTime now) {
    final int successes = current.successCount + 1;
    final double ease = (current.ease + 0.12).clamp(1.4, 3.1);
    late final int intervalDays;
    late final SrsStage stage;

    if (successes == 1) {
      intervalDays = 1;
      stage = SrsStage.learning;
    } else if (successes == 2) {
      intervalDays = 3;
      stage = SrsStage.reviewing;
    } else {
      final int baseInterval = current.intervalDays <= 0
          ? 3
          : current.intervalDays;
      intervalDays = (baseInterval * ease).round().clamp(baseInterval + 1, 180);
      stage = intervalDays >= 14 || successes >= 5
          ? SrsStage.mastered
          : SrsStage.reviewing;
    }

    return current.copyWith(
      stage: stage,
      intervalDays: intervalDays,
      ease: ease,
      successCount: successes,
      dueAt: now.add(Duration(days: intervalDays)),
      updatedAt: now,
      lastReviewedAt: now,
    );
  }

  SrsCardProgress _resetSrsCard(SrsCardProgress current, DateTime now) {
    final double ease = (current.ease - 0.18).clamp(1.3, 3.1);
    return current.copyWith(
      stage: SrsStage.learning,
      intervalDays: 0,
      ease: ease,
      failureCount: current.failureCount + 1,
      dueAt: now.add(const Duration(minutes: 15)),
      updatedAt: now,
      lastReviewedAt: now,
    );
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
      await _clearLocalUserData();
      await _loadProgressFromRemote(preferRemote: true);
    }

    if (previousId != nextId && nextUser == null) {
      await _clearLocalUserData();
    }

    notifyListeners();
  }

  Future<void> _loadProgressFromRemote({bool preferRemote = false}) async {
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
    final Map<String, dynamic> srs =
        (progress['srs'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final Map<String, String> merged = <String, String>{};
    lessons.forEach((String slug, dynamic value) {
      if (value is! Map) return;
      if (value['completed'] != true) return;
      final String key = _completionKeyFromSlug(slug);
      merged[key] = value['last_done']?.toString() ?? _todayIso();
    });
    _completedItems
      ..clear()
      ..addAll(merged);
    final Map<String, SrsCardProgress> mergedSrs = <String, SrsCardProgress>{};
    srs.forEach((String cardId, dynamic value) {
      if (value is! Map) return;
      mergedSrs[cardId] = SrsCardProgress.fromJson(
        cardId,
        value.cast<String, dynamic>(),
      );
    });
    _srsProgress
      ..clear()
      ..addAll(mergedSrs);
    _persistCompletedItems();
    _persistSrsProgress();
    notifyListeners();
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
    final Map<String, dynamic> srs = <String, dynamic>{};
    _srsProgress.forEach((String key, SrsCardProgress value) {
      srs[key] = value.toJson();
    });

    await Supabase.instance.client.from('progress').upsert(<String, dynamic>{
      'user_id': _currentUser!.id,
      'data': <String, dynamic>{
        'lessons': lessons,
        'srs': srs,
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
  }

  void _persistSrsProgress() {
  }

  Future<void> _clearLocalUserData() async {
    _completedItems.clear();
    _srsProgress.clear();
    await _prefs?.remove('completed_items');
    await _prefs?.remove('srs_progress');
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
