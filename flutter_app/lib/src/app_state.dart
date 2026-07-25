import 'dart:collection';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/content_seed.dart';
import 'data/course_seed.dart';
import 'models/content_models.dart';
import 'models/course_models.dart';
import 'models/deck_models.dart';
import 'models/srs_models.dart';
import 'services/exportable_vocab_catalog.dart';

class AppController extends ChangeNotifier {
  static const int _completionStorageVersion = 3;
  static const String _favoriteWordsStorageKey = 'favorite_word_ids_v1';
  static const String _customDecksStorageKey = 'custom_decks_v1';
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
  final List<ExportableVocabCard> _sortedExportableCards =
      <ExportableVocabCard>[];
  final Map<String, ExportableVocabCard> _srsReviewCardsById =
      <String, ExportableVocabCard>{};
  final List<ExportableVocabCard> _sortedSrsReviewCards =
      <ExportableVocabCard>[];
  final List<Map<String, String>> _allVocabItems = <Map<String, String>>[];
  final Map<String, VocabularyWord> _vocabularyWordsById =
      <String, VocabularyWord>{};
  final List<VocabularyWord> _sortedVocabularyWords = <VocabularyWord>[];
  final Set<String> _favoriteWordIds = <String>{};
  final Map<String, CustomDeck> _customDecks = <String, CustomDeck>{};
  final Map<String, SrsCardProgress> _srsProgress = <String, SrsCardProgress>{};
  final ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier<ThemeMode>(
    ThemeMode.dark,
  );
  bool _vocabLoaded = false;
  bool _darkMode = true;
  Future<void>? _loadVocabFuture;
  SharedPreferences? _prefs;
  final Map<String, String> _completedItems = <String, String>{};
  User? _currentUser;
  StreamSubscription<AuthState>? _authSubscription;
  Future<void> _progressSyncChain = Future<void>.value();

  String get selectedLanguage => _selectedLanguage;
  bool get vocabLoaded => _vocabLoaded;
  bool get darkMode => _darkMode;
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;
  ValueListenable<ThemeMode> get themeModeListenable => _themeModeNotifier;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  List<ExportableVocabCard> get exportableCards => _sortedExportableCards;
  List<ExportableVocabCard> get srsReviewCards => _sortedSrsReviewCards;
  List<Map<String, String>> get allVocabItems => _allVocabItems;
  List<VocabularyWord> get vocabularyWords =>
      UnmodifiableListView<VocabularyWord>(_sortedVocabularyWords);
  Set<String> get favoriteWordIds =>
      UnmodifiableSetView<String>(_favoriteWordIds);
  List<VocabularyWord> get favoriteWords {
    final List<VocabularyWord> words = _favoriteWordIds
        .map((String id) => _vocabularyWordsById[id])
        .whereType<VocabularyWord>()
        .toList();
    words.sort(
      (VocabularyWord a, VocabularyWord b) =>
          a.term.toLowerCase().compareTo(b.term.toLowerCase()),
    );
    return words;
  }

  List<CustomDeck> get customDecks {
    final List<CustomDeck> decks = _customDecks.values.toList();
    decks.sort((CustomDeck a, CustomDeck b) {
      final int byDate = a.createdAt.compareTo(b.createdAt);
      if (byDate != 0) return byDate;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return decks;
  }

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

    for (final String candidate in _meaningCandidates(normalized)) {
      final Map<String, String>? override = _glossaryOverrides[candidate];
      final Map<String, String>? meaning = _vocab[candidate];
      for (final String key in fallbackOrder) {
        final String? overrideValue = pick(override, key);
        if (overrideValue != null) return overrideValue;
        final String? vocabValue = pick(meaning, key);
        if (vocabValue != null) return vocabValue;
      }
    }

    return null;
  }

  Iterable<String> _meaningCandidates(String normalized) sync* {
    if (normalized.isEmpty) return;

    final Set<String> candidates = <String>{normalized};
    if (normalized.endsWith('es') && normalized.length > 2) {
      candidates.add(normalized.substring(0, normalized.length - 2));
    }
    if (normalized.endsWith('s') && normalized.length > 1) {
      candidates.add(normalized.substring(0, normalized.length - 1));
    }

    if (!normalized.endsWith('r')) {
      candidates.add('${normalized}r');
    }
    for (final String suffix in const <String>['va', 'ra', 'te']) {
      if (normalized.endsWith(suffix) && normalized.length > suffix.length) {
        candidates.add(
          '${normalized.substring(0, normalized.length - suffix.length)}r',
        );
      }
    }

    yield* candidates;
  }

  VocabularyWord? vocabularyWordForTerm(String term) =>
      _vocabularyWordsById[normalizeTerm(term)];

  bool isFavoriteWord(String term) =>
      _favoriteWordIds.contains(normalizeTerm(term));

  bool toggleFavoriteWord(String term) {
    final String wordId = normalizeTerm(term);
    if (wordId.isEmpty) return false;

    final bool isNowFavorite;
    if (_favoriteWordIds.remove(wordId)) {
      isNowFavorite = false;
    } else {
      _favoriteWordIds.add(wordId);
      isNowFavorite = true;
    }
    _persistDeckLibrary();
    notifyListeners();
    return isNowFavorite;
  }

  CustomDeck? customDeckById(String deckId) => _customDecks[deckId];

  List<VocabularyWord> wordsForCustomDeck(String deckId) {
    final CustomDeck? deck = _customDecks[deckId];
    if (deck == null) return const <VocabularyWord>[];
    return deck.wordIds
        .map((String id) => _vocabularyWordsById[id])
        .whereType<VocabularyWord>()
        .toList();
  }

  String createCustomDeck(String name) {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Le nomine non pote esser vacue');
    }
    final DateTime now = DateTime.now();
    final String id = 'custom-${now.microsecondsSinceEpoch}';
    _customDecks[id] = CustomDeck(
      id: id,
      name: trimmedName,
      wordIds: const <String>[],
      createdAt: now,
    );
    _persistDeckLibrary();
    notifyListeners();
    return id;
  }

  void deleteCustomDeck(String deckId) {
    if (_customDecks.remove(deckId) == null) return;
    _persistDeckLibrary();
    notifyListeners();
  }

  void addWordToCustomDeck(String deckId, String term) {
    final CustomDeck? deck = _customDecks[deckId];
    final String wordId = normalizeTerm(term);
    if (deck == null || wordId.isEmpty || deck.wordIds.contains(wordId)) return;
    _customDecks[deckId] = deck.copyWith(
      wordIds: <String>[...deck.wordIds, wordId],
    );
    _persistDeckLibrary();
    notifyListeners();
  }

  void removeWordFromCustomDeck(String deckId, String term) {
    final CustomDeck? deck = _customDecks[deckId];
    final String wordId = normalizeTerm(term);
    if (deck == null || !deck.wordIds.contains(wordId)) return;
    _customDecks[deckId] = deck.copyWith(
      wordIds: deck.wordIds.where((String id) => id != wordId).toList(),
    );
    _persistDeckLibrary();
    notifyListeners();
  }

  List<Map<String, String>> lessonItems(String slug) =>
      _lessonItems[slug] ?? const <Map<String, String>>[];

  List<ExportableVocabCard> exportableCardsForSlug(String slug) =>
      _exportableCardsBySlug[slug] ?? const <ExportableVocabCard>[];
  ExportableVocabCard? exportableCardById(String cardId) =>
      _srsReviewCardsById[_canonicalSrsCardId(cardId)] ??
      _exportableCardsById[cardId];

  List<ExportableVocabCard> exportableCardsForLevels(Set<String> levelSlugs) {
    return exportableCards
        .where(
          (ExportableVocabCard card) => levelSlugs.contains(card.levelSlug),
        )
        .toList();
  }

  SrsCardProgress? srsProgressForCard(String cardId) =>
      _srsProgress[_canonicalSrsCardId(cardId)];

  SrsCardProgress? srsProgressForSlugTerm(String slug, String term) {
    return _srsProgress[_srsCardIdForTerm(term)];
  }

  ExportableVocabCard? srsCardForSlugTerm(String slug, String term) {
    return _exportableCardsById['$slug:${term.trim().toLowerCase()}'] ??
        _srsReviewCardsById[_srsCardIdForTerm(term)];
  }

  List<String> srsCardIdsForTerms(Iterable<String> terms) {
    return terms
        .map(_srsCardIdForTerm)
        .where(_srsReviewCardsById.containsKey)
        .toSet()
        .toList();
  }

  Future<void> initialize() async {
    _currentUser = Supabase.instance.client.auth.currentUser;
    _prefs = await SharedPreferences.getInstance();
    _selectedLanguage =
        _prefs?.getString('selected_language') ?? _selectedLanguage;
    _darkMode = _prefs?.getBool('dark_mode') ?? true;
    _themeModeNotifier.value = themeMode;
    _loadDeckLibrary();
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
    final Future<void> inFlight = _loadVocabFuture ??= _loadVocabInternal();
    try {
      await inFlight;
    } finally {
      if (identical(_loadVocabFuture, inFlight)) {
        _loadVocabFuture = null;
      }
    }
  }

  Future<void> _loadVocabInternal() async {
    final String raw = await rootBundle.loadString('assets/data/vocab.json');
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    final Map<String, Map<String, String>> parsed =
        <String, Map<String, String>>{};
    final Map<String, List<Map<String, String>>> parsedLessonItems =
        <String, List<Map<String, String>>>{};
    final List<Map<String, String>> flattenedItems = <Map<String, String>>[];
    final Map<String, VocabularyWord> parsedVocabularyWords =
        <String, VocabularyWord>{};

    for (final MapEntry<String, dynamic> entry in data.entries) {
      final dynamic value = entry.value;
      if (value is! List<dynamic>) continue;
      final List<Map<String, String>> lessonList = <Map<String, String>>[];
      for (final dynamic item in value) {
        if (item is! Map<String, dynamic>) continue;
        final String term = normalizeTerm(item['term'] as String? ?? '');
        if (term.isEmpty) continue;
        final Map<String, String> normalizedItem = item.map(
          (dynamic key, dynamic value) =>
              MapEntry(key.toString(), value?.toString() ?? ''),
        );
        final Map<String, String> translations = <String, String>{};
        normalizedItem.forEach((String key, String value) {
          if (key == 'term' || value.isEmpty) return;
          translations[key] = value;
        });
        parsed[term] = translations;
        parsedVocabularyWords[term] = VocabularyWord(
          id: term,
          term: (normalizedItem['term'] ?? term).trim(),
          translations: Map<String, String>.unmodifiable(translations),
        );
        lessonList.add(normalizedItem);
      }
      parsedLessonItems[entry.key] = lessonList;
      flattenedItems.addAll(lessonList);
    }

    for (final MapEntry<String, VocabMeaning> entry in vocabMeanings.entries) {
      final String term = normalizeTerm(entry.value.term);
      if (term.isEmpty) continue;
      final Map<String, String> translations = Map<String, String>.from(
        entry.value.meanings,
      );
      parsed.putIfAbsent(term, () => translations);
      parsedVocabularyWords.putIfAbsent(
        term,
        () => VocabularyWord(
          id: term,
          term: entry.value.term,
          translations: Map<String, String>.unmodifiable(translations),
        ),
      );
    }

    _lessonItems
      ..clear()
      ..addAll(parsedLessonItems);
    _allVocabItems
      ..clear()
      ..addAll(flattenedItems);
    _vocabularyWordsById
      ..clear()
      ..addAll(parsedVocabularyWords);
    _sortedVocabularyWords
      ..clear()
      ..addAll(parsedVocabularyWords.values)
      ..sort(
        (VocabularyWord a, VocabularyWord b) =>
            a.term.toLowerCase().compareTo(b.term.toLowerCase()),
      );
    _vocab = parsed;
    final List<ExportableVocabCard> catalog = buildExportableVocabCatalog(
      _lessonItems,
    );
    _sortedExportableCards
      ..clear()
      ..addAll(catalog)
      ..sort((ExportableVocabCard a, ExportableVocabCard b) {
        final int byLevel = a.levelTitle.compareTo(b.levelTitle);
        if (byLevel != 0) return byLevel;
        return a.term.compareTo(b.term);
      });
    _exportableCardsById
      ..clear()
      ..addEntries(
        _sortedExportableCards.map(
          (ExportableVocabCard card) =>
              MapEntry<String, ExportableVocabCard>(card.id, card),
        ),
      );
    _exportableCardsBySlug
      ..clear()
      ..addEntries(
        _sortedExportableCards.fold<Map<String, List<ExportableVocabCard>>>(
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
    _buildSrsReviewCatalog();
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
    _themeModeNotifier.value = themeMode;
    _prefs?.setBool('dark_mode', _darkMode);
    notifyListeners();
  }

  void markCompleted(String key) {
    final String timestamp = DateTime.now().toIso8601String();
    _completedItems[key] = timestamp;
    final String slug = _slugFromCompletionKey(key);
    if ((_lessonItems[slug] ?? const <Map<String, String>>[]).isNotEmpty) {
      registerVocabularySeen(slug);
    }
    _persistCompletedItems();
    _scheduleProgressSync();
    notifyListeners();
  }

  void clearCompleted(String key) {
    if (_completedItems.remove(key) == null) return;
    _persistCompletedItems();
    _scheduleProgressSync();
    notifyListeners();
  }

  bool isCompleted(String key) => _completedItems.containsKey(key);

  String? completionDate(String key) => _completedItems[key];

  void registerVocabularySeen(String slug) {
    final List<String> cardIds = srsCardIdsForTerms(
      (_lessonItems[slug] ?? const <Map<String, String>>[]).map(
        (Map<String, String> item) => item['term'] ?? '',
      ),
    );
    if (cardIds.isEmpty) return;
    final DateTime now = DateTime.now();
    bool changed = false;
    for (final String cardId in cardIds) {
      if (_srsProgress.containsKey(cardId)) continue;
      _srsProgress[cardId] = SrsCardProgress(
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
      changed = true;
    }
    if (!changed) return;
    _persistSrsProgress();
    _scheduleProgressSync();
    notifyListeners();
  }

  void recordSrsReview(String cardId, {required bool success}) {
    final ExportableVocabCard? card = exportableCardById(cardId);
    if (card == null) return;
    final String globalCardId = _srsCardIdForTerm(card.term);
    final DateTime now = DateTime.now();
    final SrsCardProgress current =
        _srsProgress[globalCardId] ??
        SrsCardProgress(
          cardId: globalCardId,
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
    _srsProgress[globalCardId] = next;
    _persistSrsProgress();
    _scheduleProgressSync();
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

  void _buildSrsReviewCatalog() {
    final Map<String, ExportableVocabCard> firstCourseCardByWordId =
        <String, ExportableVocabCard>{};
    for (final ExportableVocabCard card in _sortedExportableCards) {
      firstCourseCardByWordId.putIfAbsent(
        _srsCardIdForTerm(card.term),
        () => card,
      );
    }

    _srsReviewCardsById.clear();
    for (final VocabularyWord word in _sortedVocabularyWords) {
      final String cardId = _srsCardIdForTerm(word.term);
      final ExportableVocabCard? courseCard = firstCourseCardByWordId[cardId];
      _srsReviewCardsById[cardId] = ExportableVocabCard(
        id: cardId,
        term: word.term,
        translations: word.translations,
        levelSlug: courseCard?.levelSlug ?? 'vocabulario',
        levelTitle: courseCard?.levelTitle ?? 'Vocabulario',
        sourceSlug: courseCard?.sourceSlug ?? 'vocabulario',
        sourceTitle: courseCard?.sourceTitle ?? 'Vocabulario del app',
      );
    }

    _sortedSrsReviewCards
      ..clear()
      ..addAll(_srsReviewCardsById.values)
      ..sort(
        (ExportableVocabCard a, ExportableVocabCard b) =>
            a.term.toLowerCase().compareTo(b.term.toLowerCase()),
      );
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
        .replaceAll(RegExp(r'[^\wáéíóúüñàèìòùâêîôûäëïöç-]', unicode: true), '')
        .toLowerCase();
  }

  static String _srsCardIdForTerm(String term) => 'word:${normalizeTerm(term)}';

  static String _canonicalSrsCardId(String cardId) {
    final String trimmed = cardId.trim();
    if (trimmed.startsWith('word:')) {
      return _srsCardIdForTerm(trimmed.substring('word:'.length));
    }
    final int separator = trimmed.indexOf(':');
    return _srsCardIdForTerm(
      separator < 0 ? trimmed : trimmed.substring(separator + 1),
    );
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
    bool migratedLegacySrs = false;
    srs.forEach((String cardId, dynamic value) {
      if (value is! Map) return;
      final String globalCardId = _canonicalSrsCardId(cardId);
      migratedLegacySrs = migratedLegacySrs || globalCardId != cardId;
      final SrsCardProgress candidate = SrsCardProgress.fromJson(
        cardId,
        value.cast<String, dynamic>(),
      ).copyWith(cardId: globalCardId);
      final SrsCardProgress? existing = mergedSrs[globalCardId];
      if (existing == null ||
          candidate.updatedAt.isAfter(existing.updatedAt) ||
          (candidate.updatedAt == existing.updatedAt &&
              candidate.successCount > existing.successCount)) {
        mergedSrs[globalCardId] = candidate;
      }
    });
    _srsProgress
      ..clear()
      ..addAll(mergedSrs);
    _persistCompletedItems();
    _persistSrsProgress();
    if (migratedLegacySrs) {
      _scheduleProgressSync();
    }
    notifyListeners();
  }

  void _scheduleProgressSync() {
    if (_currentUser == null) return;
    _progressSyncChain = _progressSyncChain
        .then((_) => _syncProgressToRemote())
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Progress sync failed: $error');
        });
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

  void _persistSrsProgress() {}

  void _loadDeckLibrary() {
    _favoriteWordIds
      ..clear()
      ..addAll(
        (_prefs?.getStringList(_favoriteWordsStorageKey) ?? const <String>[])
            .map(normalizeTerm)
            .where((String id) => id.isNotEmpty),
      );

    _customDecks.clear();
    final String? encodedDecks = _prefs?.getString(_customDecksStorageKey);
    if (encodedDecks == null || encodedDecks.trim().isEmpty) return;

    try {
      final dynamic decoded = jsonDecode(encodedDecks);
      if (decoded is! List<dynamic>) return;
      for (final dynamic value in decoded) {
        if (value is! Map<String, dynamic>) continue;
        final CustomDeck deck = CustomDeck.fromJson(value);
        if (deck.id.isEmpty || deck.name.trim().isEmpty) continue;
        _customDecks[deck.id] = deck;
      }
    } on FormatException {
      _customDecks.clear();
    }
  }

  void _persistDeckLibrary() {
    final List<String> favorites = _favoriteWordIds.toList()..sort();
    _prefs?.setStringList(_favoriteWordsStorageKey, favorites);
    _prefs?.setString(
      _customDecksStorageKey,
      jsonEncode(customDecks.map((CustomDeck deck) => deck.toJson()).toList()),
    );
  }

  Future<void> _clearLocalUserData() async {
    _completedItems.clear();
    _srsProgress.clear();
    _favoriteWordIds.clear();
    _customDecks.clear();
    await _prefs?.remove('completed_items');
    await _prefs?.remove('srs_progress');
    await _prefs?.remove(_favoriteWordsStorageKey);
    await _prefs?.remove(_customDecksStorageKey);
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
    _themeModeNotifier.dispose();
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
