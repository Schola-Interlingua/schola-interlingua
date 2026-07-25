import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../data/course_seed.dart';
import '../models/course_models.dart';
import '../models/srs_models.dart';
import '../theme/app_theme.dart';
import '../widgets/meaning_rich_text.dart';

const Map<String, String> _languageLabels = <String, String>{
  'es': 'Español',
  'en': 'English',
  'ru': 'Русский',
  'de': 'Deutsch',
  'fr': 'Français',
  'it': 'Italiano',
  'la': 'Lingua Latina',
  'eo': 'Esperanto',
  'pt': 'Português',
  'zh': '中文',
  'ja': '日本語',
  'ca': 'Català',
  'ko': '한국어',
};

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const <Widget>[
        _InlineVocabSearch(),
        SizedBox(height: 24),
        _TextReaderCard(),
        SizedBox(height: 24),
        _ProgressCard(),
        SizedBox(height: 16),
        _SrsOverviewCard(),
        SizedBox(height: 24),
        _QuickReviewCard(),
        SizedBox(height: 24),
        _AccessCard(),
      ],
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard();

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            controller.isAuthenticated ? 'Session aperte' : 'Accesso',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            controller.isAuthenticated
                ? controller.currentUser?.email ?? 'Tu session es active.'
                : 'Tu pote entrar pro synchronisar progresso o continuar como invitato.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/entrar'),
            child: Text(
              controller.isAuthenticated ? 'Gerer accesso' : 'Entrar',
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineVocabSearch extends StatefulWidget {
  const _InlineVocabSearch();

  @override
  State<_InlineVocabSearch> createState() => _InlineVocabSearchState();
}

class _InlineVocabSearchState extends State<_InlineVocabSearch> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String language =
        _languageLabels[controller.selectedLanguage] ??
        controller.selectedLanguage;
    final List<_VocabSearchResult> results = _buildResults(
      controller.allVocabItems,
      controller.selectedLanguage,
      _query,
    );
    final bool showResults = _query.trim().isNotEmpty;
    final bool compact = MediaQuery.sizeOf(context).width < 430;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 18,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.borderColor(context),
              width: 1.2,
            ),
            boxShadow: AppTheme.glassShadow(context),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.search_rounded,
                size: compact ? 26 : 28,
                color: dark ? const Color(0xFF8BC8FF) : AppTheme.primaryLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (String value) {
                    setState(() {
                      _query = value;
                    });
                  },
                  style: TextStyle(
                    fontSize: compact ? 18 : 20,
                    color: AppTheme.textColor(context),
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Cerca in Interlingua o in $language',
                    hintStyle: TextStyle(
                      fontSize: compact ? 18 : 20,
                      color: AppTheme.mutedTextColor(context),
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              if (showResults)
                IconButton(
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _query = '';
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                  color: AppTheme.mutedTextColor(context),
                ),
            ],
          ),
        ),
        if (showResults) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.borderColor(context),
                width: 1.2,
              ),
              boxShadow: AppTheme.glassShadow(context),
            ),
            child: results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(22),
                    child: Text(
                      'Nulle resultato trovate pro "${_controller.text.trim()}".',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.mutedTextColor(context),
                      ),
                    ),
                  )
                : Column(
                    children: List<Widget>.generate(results.take(8).length, (
                      int index,
                    ) {
                      final List<_VocabSearchResult> visibleResults = results
                          .take(8)
                          .toList();
                      return _SearchResultTile(
                        item: visibleResults[index],
                        isLast: index == visibleResults.length - 1,
                      );
                    }),
                  ),
          ),
        ],
      ],
    );
  }

  List<_VocabSearchResult> _buildResults(
    List<Map<String, String>> items,
    String language,
    String query,
  ) {
    final String normalizedQuery = _normalizeSearch(query);
    final Map<String, _VocabSearchResult> unique =
        <String, _VocabSearchResult>{};

    for (final Map<String, String> item in items) {
      final String term = (item['term'] ?? '').trim();
      if (term.isEmpty) continue;
      final String translation = (item[language] ?? item['es'] ?? '').trim();
      if (translation.isEmpty) continue;

      final bool matchesTerm = _normalizeSearch(term).contains(normalizedQuery);
      final bool matchesTranslation = _normalizeSearch(
        translation,
      ).contains(normalizedQuery);
      if (!matchesTerm && !matchesTranslation) continue;

      final _VocabSearchResult result = _VocabSearchResult(
        term: term,
        translation: translation,
      );
      final String key = '${term.toLowerCase()}|${translation.toLowerCase()}';
      unique.putIfAbsent(key, () => result);
    }

    final List<_VocabSearchResult> results = unique.values.toList();
    results.sort((_VocabSearchResult a, _VocabSearchResult b) {
      final bool aStarts =
          _normalizeSearch(a.term).startsWith(normalizedQuery) ||
          _normalizeSearch(a.translation).startsWith(normalizedQuery);
      final bool bStarts =
          _normalizeSearch(b.term).startsWith(normalizedQuery) ||
          _normalizeSearch(b.translation).startsWith(normalizedQuery);
      if (aStarts != bStarts) return aStarts ? -1 : 1;
      return a.term.compareTo(b.term);
    });
    return results;
  }

  String _normalizeSearch(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^\w\s]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _TextReaderCard extends StatefulWidget {
  const _TextReaderCard();

  @override
  State<_TextReaderCard> createState() => _TextReaderCardState();
}

class _TextReaderCardState extends State<_TextReaderCard> {
  late final _ReaderTextEditingController _controller;
  final GlobalKey _readerFieldKey = GlobalKey();
  String _text = '';
  Offset? _pointerDownPosition;

  @override
  void initState() {
    super.initState();
    _controller = _ReaderTextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppStateScope.of(context).loadVocab();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _text = '';
    });
  }

  void _showMeaningAt(Offset globalPosition) {
    final RenderEditable? editable = _findRenderEditable();
    if (editable == null || _controller.text.isEmpty) {
      return;
    }

    final TextPosition position = editable.getPositionForPoint(globalPosition);
    final int offset = position.offset.clamp(0, _controller.text.length);
    final RegExp wordPattern = RegExp(
      r"[\wáéíóúüñàèìòùâêîôûäëïöç]+(?:[-'][\wáéíóúüñàèìòùâêîôûäëïöç]+)*",
      unicode: true,
    );
    RegExpMatch? tappedWord;
    for (final RegExpMatch match in wordPattern.allMatches(_controller.text)) {
      if (offset >= match.start && offset <= match.end) {
        tappedWord = match;
        break;
      }
    }
    if (tappedWord == null) {
      return;
    }

    final String word = tappedWord.group(0)!;
    final AppController controller = AppStateScope.of(context);
    if (controller.resolveMeaning(word, controller.selectedLanguage) == null) {
      return;
    }

    FocusScope.of(context).unfocus();
    showWordMeaningMenu(
      context: context,
      globalPosition: globalPosition,
      word: word,
    );
  }

  RenderEditable? _findRenderEditable() {
    final BuildContext? fieldContext = _readerFieldKey.currentContext;
    if (fieldContext == null) {
      return null;
    }

    RenderEditable? result;
    void visit(Element element) {
      if (result != null) {
        return;
      }
      final RenderObject? renderObject = element.renderObject;
      if (renderObject is RenderEditable) {
        result = renderObject;
        return;
      }
      element.visitChildren(visit);
    }

    visit(fieldContext as Element);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = _text.trim().isNotEmpty;
    final bool compact = MediaQuery.sizeOf(context).width < 520;

    return ScholaCard(
      padding: EdgeInsets.all(compact ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.interactiveTextColor(
                    context,
                  ).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor(context)),
                ),
                child: Icon(
                  Icons.chrome_reader_mode_rounded,
                  color: AppTheme.interactiveTextColor(context),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Lector de textos',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Incolla un texto in Interlingua e tocca le parolas sublineate pro vider lor traduction.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.mutedTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Listener(
            key: _readerFieldKey,
            onPointerDown: (PointerDownEvent event) {
              _pointerDownPosition = event.position;
            },
            onPointerMove: (PointerMoveEvent event) {
              final Offset? start = _pointerDownPosition;
              if (start != null && (event.position - start).distance > 8) {
                _pointerDownPosition = null;
              }
            },
            onPointerCancel: (_) {
              _pointerDownPosition = null;
            },
            onPointerUp: (PointerUpEvent event) {
              if (_pointerDownPosition != null) {
                _showMeaningAt(event.position);
              }
              _pointerDownPosition = null;
            },
            child: TextField(
              key: const Key('home-reader-input'),
              controller: _controller,
              minLines: 4,
              maxLines: 9,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (String value) {
                setState(() {
                  _text = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Incolla hic le texto que tu vole leger...',
                suffixIcon: hasText
                    ? IconButton(
                        key: const Key('home-reader-clear'),
                        onPressed: _clear,
                        tooltip: 'Vacuar',
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReaderTextEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final AppController controller = AppStateScope.of(context);
    final String language = controller.selectedLanguage;
    final List<String> tokens = RegExp(
      r'[\wáéíóúüñàèìòùâêîôûäëïöç]+|\s+|[^\s\wáéíóúüñàèìòùâêîôûäëïöç]+',
      unicode: true,
    ).allMatches(text).map((RegExpMatch match) => match.group(0)!).toList();

    return TextSpan(
      style: style,
      children: <InlineSpan>[
        for (final String token in tokens)
          TextSpan(
            text: token,
            style: controller.resolveMeaning(token, language) == null
                ? null
                : TextStyle(
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dotted,
                    decorationColor: AppTheme.interactiveTextColor(context),
                    color: AppTheme.interactiveTextColor(context),
                    fontWeight: FontWeight.w500,
                  ),
          ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final List<String> trackableKeys = _trackableCompletionKeys();
    final int totalItems = trackableKeys.length;
    final int completedItems = trackableKeys
        .where(controller.isCompleted)
        .length;
    final double progress = totalItems == 0 ? 0 : completedItems / totalItems;
    final int percent = (progress * 100).round();
    final int streak = controller.consecutiveDaysStreak;
    final String summary = completedItems == 0
        ? 'Tu non ha ancora comenciate'
        : '$completedItems de $totalItems completate ($percent%)';

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Tu progresso',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(summary, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppTheme.borderColor(context)),
              boxShadow: AppTheme.glassShadow(context),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0, 1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[AppTheme.primary, AppTheme.primaryLight],
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppTheme.primaryLight.withValues(alpha: 0.35),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              const Text('🔥', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$streak dies consecutive',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _trackableCompletionKeys() {
    return courseLevels
        .expand((CourseLevel level) => level.sections)
        .expand((CourseSection section) => section.items)
        .map((CourseItemRef item) {
          switch (item.kind) {
            case CourseItemKind.lesson:
            case CourseItemKind.vocabulary:
              return 'lesson:${item.slug}';
            case CourseItemKind.reading:
              return 'reading:${item.slug}';
            case CourseItemKind.appendix:
              return 'appendix:${item.slug}';
          }
        })
        .toList();
  }
}

class _SrsOverviewCard extends StatelessWidget {
  const _SrsOverviewCard();

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final Map<SrsStage, int> counts = controller.srsStageCounts;
    final int total = controller.trackedSrsWordCount;
    final int due = controller.dueSrsWordCount;
    const Map<SrsStage, Color> colors = <SrsStage, Color>{
      SrsStage.newWord: Color(0xFF7C8AA5),
      SrsStage.learning: Color(0xFF3BA4FF),
      SrsStage.reviewing: Color(0xFF20C997),
      SrsStage.mastered: Color(0xFFF5B942),
    };
    const Map<SrsStage, String> labels = <SrsStage, String>{
      SrsStage.newWord: 'Nove',
      SrsStage.learning: 'In studio',
      SrsStage.reviewing: 'In revision',
      SrsStage.mastered: 'Apprendite',
    };

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Parolas e repetition',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            total == 0
                ? 'Nulle parola ha entrate ancora in le repetition integrate.'
                : '$total parolas in le systema. $due debite ora.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Container(
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppTheme.borderColor(context)),
            ),
            child: total == 0
                ? const SizedBox.expand()
                : Row(
                    children: SrsStage.values.map((SrsStage stage) {
                      final int count = counts[stage] ?? 0;
                      if (count == 0) {
                        return const SizedBox.shrink();
                      }
                      return Expanded(
                        flex: count,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors[stage],
                            borderRadius: BorderRadius.only(
                              topLeft: stage == SrsStage.values.first
                                  ? const Radius.circular(999)
                                  : Radius.zero,
                              bottomLeft: stage == SrsStage.values.first
                                  ? const Radius.circular(999)
                                  : Radius.zero,
                              topRight: stage == SrsStage.values.last
                                  ? const Radius.circular(999)
                                  : Radius.zero,
                              bottomRight: stage == SrsStage.values.last
                                  ? const Radius.circular(999)
                                  : Radius.zero,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: SrsStage.values.map((SrsStage stage) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[stage],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${labels[stage]}: ${counts[stage] ?? 0}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.item, required this.isLast});

  final _VocabSearchResult item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final bool isFavorite = controller.isFavoriteWord(item.term);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFDCE4EE).withValues(alpha: 0.9),
                ),
              ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.term,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(context),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.translation,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mutedTextColor(context),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            key: ValueKey<String>(
              'search-favorite-${AppController.normalizeTerm(item.term)}',
            ),
            onPressed: () {
              controller.toggleFavoriteWord(item.term);
            },
            tooltip: isFavorite
                ? 'Retirar del favoritos'
                : 'Adder al favoritos',
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite
                  ? const Color(0xFFE54867)
                  : AppTheme.mutedTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabSearchResult {
  const _VocabSearchResult({required this.term, required this.translation});

  final String term;
  final String translation;
}

class _QuickReviewCard extends StatelessWidget {
  const _QuickReviewCard();

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final int due = controller.dueSrsWordCount;

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Repaso rapide',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            due == 0
                ? 'Tu non ha cartas debite ora. Quando tu vide vocabulario del curso, illos appare hic automaticamente.'
                : 'Tu ha $due cartas preste pro un quiz rapide.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: due == 0 ? null : () => context.go('/review'),
            icon: const Icon(Icons.bolt_rounded),
            label: Text(due == 0 ? 'Nulle repaso ora' : 'Repasar ora'),
          ),
        ],
      ),
    );
  }
}
