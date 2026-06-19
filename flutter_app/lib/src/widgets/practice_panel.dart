import 'dart:math';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';

class PracticePanel extends StatelessWidget {
  const PracticePanel({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final List<Map<String, String>> items = controller.lessonItems(slug);
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _VocabularyTable(items: items),
        const SizedBox(height: 24),
        _ClassicReviewCard(items: items),
        const SizedBox(height: 24),
        _QuizCard(items: items),
      ],
    );
  }
}

class _VocabularyTable extends StatefulWidget {
  const _VocabularyTable({required this.items});

  final List<Map<String, String>> items;

  @override
  State<_VocabularyTable> createState() => _VocabularyTableState();
}

class _VocabularyTableState extends State<_VocabularyTable> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final String lang = controller.selectedLanguage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextButton.icon(
          onPressed: () => setState(() => _visible = !_visible),
          icon: Icon(_visible ? Icons.visibility_off : Icons.menu_book_rounded),
          label: Text(_visible ? 'Celar vocabulario' : 'Monstrar vocabulario'),
        ),
        if (_visible)
          ScholaCard(
            padding: const EdgeInsets.all(0),
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: <TableRow>[
                TableRow(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        AppTheme.primary.withValues(alpha: 0.96),
                        AppTheme.primaryLight.withValues(alpha: 0.86),
                      ],
                    ),
                  ),
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(14),
                      child: Text(
                        'Interlingua',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(14),
                      child: Text(
                        'Tu lingua',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                ...widget.items.map(
                  (Map<String, String> item) => TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.borderColor(context),
                        ),
                      ),
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(item['term'] ?? ''),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(item[lang] ?? item['es'] ?? ''),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _QuizCard extends StatefulWidget {
  const _QuizCard({required this.items});

  final List<Map<String, String>> items;

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  late final Random _random;
  int _index = 0;
  List<String> _choices = <String>[];
  String? _selected;
  bool _autoAdvancing = false;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _refresh();
  }

  void _refresh() {
    final current = widget.items[_index % widget.items.length];
    final String correct = current['term'] ?? '';
    final List<String> distractors =
        widget.items
            .where((item) => item['term'] != correct)
            .map((item) => item['term'] ?? '')
            .take(8)
            .toList()
          ..shuffle(_random);
    _choices = <String>[correct, ...distractors.take(3)]..shuffle(_random);
    _selected = null;
    _autoAdvancing = false;
  }

  void _goToNext() {
    setState(() {
      _index = (_index + 1) % widget.items.length;
      _refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final String lang = controller.selectedLanguage;
    final current = widget.items[_index % widget.items.length];
    final String prompt = current[lang] ?? current['es'] ?? '';
    final String correct = current['term'] ?? '';

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Quiz rapide', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Text(
            prompt,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          ..._choices.map((String choice) {
            final bool selected = _selected == choice;
            final bool isCorrect = choice == correct;
            Color background = AppTheme.cardColor(context);
            Color border = AppTheme.borderColor(context);
            Color foreground = AppTheme.textColor(context);
            if (_selected != null) {
              if (isCorrect) {
                background = const Color(0xFFD4EDDA);
                border = const Color(0xFF198754);
                foreground = const Color(0xFF155724);
              } else if (selected && !isCorrect) {
                background = const Color(0xFFF8D7DA);
                border = const Color(0xFFDC3545);
                foreground = const Color(0xFF842029);
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed:
                      (_selected != null && _autoAdvancing) ||
                          _selected == choice
                      ? null
                      : () {
                          setState(() {
                            _selected = choice;
                          });
                          if (isCorrect) {
                            _autoAdvancing = true;
                            Future<void>.delayed(
                              const Duration(milliseconds: 650),
                              () {
                                if (!mounted || !_autoAdvancing) return;
                                _goToNext();
                              },
                            );
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: border, width: 2),
                    backgroundColor: background,
                    foregroundColor: foreground,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 22,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    choice,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
          if (_selected != null && !_autoAdvancing)
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: _goToNext,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                child: const Text('Sequente'),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClassicReviewCard extends StatefulWidget {
  const _ClassicReviewCard({required this.items});

  final List<Map<String, String>> items;

  @override
  State<_ClassicReviewCard> createState() => _ClassicReviewCardState();
}

class _ClassicReviewCardState extends State<_ClassicReviewCard> {
  final TextEditingController _controller = TextEditingController();
  late final Random _random;
  late List<Map<String, String>> _queue;
  int _index = 0;
  String? _feedback;
  bool? _correct;
  int _hintLevel = 0;
  bool _gaveUp = false;
  List<_LetterTile> _letterTiles = const <_LetterTile>[];
  final List<int> _tileUsageStack = <int>[];
  String? _activeLang;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _queue = List<Map<String, String>>.from(widget.items)..shuffle(_random);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String lang = AppStateScope.of(context).selectedLanguage;
    if (_activeLang != lang || _letterTiles.isEmpty) {
      _activeLang = lang;
      _resetReviewState(lang);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppController app = AppStateScope.of(context);
    final String lang = app.selectedLanguage;
    final Map<String, String> item = _queue[_index % _queue.length];
    final _AnswerData answerData = _answerDataFor(item, lang);
    final String expected = answerData.answer;
    final String prompt = item['term'] ?? '';
    final bool answered = _feedback != null;

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Revider', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.26),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.borderColor(context)),
              boxShadow: AppTheme.glassShadow(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Scribe le traduction correcte',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: answered
                          ? null
                          : () {
                              setState(() {
                                _gaveUp = true;
                                _correct = false;
                                _feedback = 'Responsa: $expected';
                              });
                            },
                      icon: const Icon(Icons.question_mark_rounded),
                      label: const Text('Io non lo sape'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        side: BorderSide(color: AppTheme.borderColor(context)),
                        foregroundColor: AppTheme.textColor(context),
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Carta ${_index + 1} / ${_queue.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Text('Traduce:', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    prompt,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  enabled: !answered,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu respuesta',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Toca solo litteras correcte (in disordine)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _letterTiles.map((tile) {
                    return OutlinedButton(
                      onPressed: answered || tile.used
                          ? null
                          : () => _appendFromTile(tile.index),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(44, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        side: BorderSide(
                          color: tile.used
                              ? AppTheme.borderColor(context)
                              : const Color(0xFFBEC9D9),
                        ),
                        backgroundColor: tile.used
                            ? AppTheme.surfaceVariant(context)
                            : AppTheme.cardColor(context),
                        foregroundColor: tile.used
                            ? AppTheme.mutedTextColor(context)
                            : AppTheme.textColor(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(tile.char),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    FilledButton(
                      onPressed: answered
                          ? null
                          : () {
                              setState(() {
                                _hintLevel = (_hintLevel + 1).clamp(0, 3);
                                final int nextLength =
                                    (_controller.text.length + 1).clamp(
                                      0,
                                      expected.length,
                                    );
                                _controller.text = expected.substring(
                                  0,
                                  nextLength,
                                );
                                _controller.selection = TextSelection.collapsed(
                                  offset: _controller.text.length,
                                );
                              });
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6C757D),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Indicio'),
                    ),
                    OutlinedButton(
                      onPressed: answered ? null : _removeLastFromInput,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.borderColor(context)),
                        foregroundColor: AppTheme.textColor(context),
                      ),
                      child: const Text('⌫'),
                    ),
                    FilledButton(
                      onPressed: answered
                          ? null
                          : () {
                              setState(() {
                                final String normalizedAnswer =
                                    _normalizeReview(_controller.text);
                                _correct =
                                    answerData.alternatives.any(
                                      (String value) =>
                                          _normalizeReview(value) ==
                                          normalizedAnswer,
                                    ) &&
                                    !_gaveUp &&
                                    _hintLevel < 3;
                                _feedback = _correct!
                                    ? 'Correcte'
                                    : 'Responsa: ${answerData.answer}';
                              });
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF20C997),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Verificar'),
                    ),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _index = (_index + 1) % _queue.length;
                          _resetReviewState(lang);
                        });
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Sequente'),
                    ),
                  ],
                ),
                if (_feedback != null) ...<Widget>[
                  const SizedBox(height: 14),
                  Text(
                    _feedback!,
                    style: TextStyle(
                      color: (_correct ?? false)
                          ? const Color(0xFF198754)
                          : const Color(0xFFDC3545),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _AnswerData _answerDataFor(Map<String, String> item, String lang) {
    final String raw = item[lang] ?? item['es'] ?? '';
    final List<String> alternatives = raw
        .split(RegExp(r'[\/;]'))
        .map((String value) => value.split('(').first.split(',').first.trim())
        .where((String value) => value.isNotEmpty)
        .toList();
    final String answer = alternatives.isNotEmpty
        ? alternatives.first
        : raw.trim();
    return _AnswerData(
      answer: answer,
      alternatives: alternatives.isEmpty ? <String>[answer] : alternatives,
    );
  }

  List<_LetterTile> _buildLetterTiles(String answer) {
    final List<String> chars =
        answer.split('').where((String char) => char.trim().isNotEmpty).toList()
          ..shuffle(_random);
    return List<_LetterTile>.generate(
      chars.length,
      (int index) => _LetterTile(index: index, char: chars[index]),
    );
  }

  void _appendFromTile(int tileIndex) {
    final _LetterTile tile = _letterTiles[tileIndex];
    if (tile.used) return;
    setState(() {
      _controller.text += tile.char;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      _tileUsageStack.add(tileIndex);
      _letterTiles = _letterTiles
          .map(
            (_LetterTile current) => current.index == tileIndex
                ? current.copyWith(used: true)
                : current,
          )
          .toList();
    });
  }

  void _removeLastFromInput() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _controller.text = _controller.text.substring(
        0,
        _controller.text.length - 1,
      );
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
      if (_tileUsageStack.isNotEmpty) {
        final int lastTile = _tileUsageStack.removeLast();
        _letterTiles = _letterTiles
            .map(
              (_LetterTile current) => current.index == lastTile
                  ? current.copyWith(used: false)
                  : current,
            )
            .toList();
      }
    });
  }

  void _resetReviewState(String lang) {
    _controller.clear();
    _feedback = null;
    _correct = null;
    _hintLevel = 0;
    _gaveUp = false;
    _tileUsageStack.clear();
    final String answer = _answerDataFor(
      _queue[_index % _queue.length],
      lang,
    ).answer;
    _letterTiles = _buildLetterTiles(answer);
  }

  String _normalizeReview(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }
}

class _AnswerData {
  const _AnswerData({required this.answer, required this.alternatives});

  final String answer;
  final List<String> alternatives;
}

class _LetterTile {
  const _LetterTile({
    required this.index,
    required this.char,
    this.used = false,
  });

  final int index;
  final String char;
  final bool used;

  _LetterTile copyWith({bool? used}) {
    return _LetterTile(index: index, char: char, used: used ?? this.used);
  }
}
