import 'dart:math';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/meaning_rich_text.dart';

class WordsearchScreen extends StatefulWidget {
  const WordsearchScreen({super.key});

  @override
  State<WordsearchScreen> createState() => _WordsearchScreenState();
}

class _WordsearchScreenState extends State<WordsearchScreen> {
  static const int _gridSize = 10;
  static const int _minWords = 6;
  static const int _maxWords = 8;
  static const String _letters = 'abcdefghijklmnopqrstuvwxyz';

  final Random _random = Random();
  final Set<String> _foundWords = <String>{};
  final Set<_GridCell> _foundCells = <_GridCell>{};
  final GlobalKey _boardKey = GlobalKey();

  List<String> _words = const <String>[];
  List<List<String>> _grid = List<List<String>>.generate(
    _gridSize,
    (_) => List<String>.filled(_gridSize, ''),
  );
  List<_GridCell> _selectedCells = const <_GridCell>[];
  _GridCell? _startCell;
  bool _isSelecting = false;
  bool _roundComplete = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppStateScope.of(context).loadVocab();
    if (_words.isEmpty) {
      _newRound();
    }
  }

  void _newRound() {
    final AppController controller = AppStateScope.of(context);
    final List<String> allTerms =
        controller.allVocabItems
            .map((Map<String, String> item) => item['term'] ?? '')
            .where((String term) {
              final String normalized = _normalizeWord(term);
              return normalized.length >= 3 && normalized.length <= 8;
            })
            .toSet()
            .toList()
          ..shuffle(_random);
    final List<String> fallbackWords = <String>[
      'io',
      'tu',
      'nos',
      'gratia',
      'schola',
      'lingua',
    ];

    final int targetCount =
        _minWords + _random.nextInt(_maxWords - _minWords + 1);
    final List<String> selectedWords =
        (allTerms.isEmpty ? fallbackWords : allTerms)
            .take(targetCount)
            .toList();

    setState(() {
      _words = selectedWords;
      _grid = _buildGrid(selectedWords);
      _foundWords.clear();
      _foundCells.clear();
      _selectedCells = const <_GridCell>[];
      _startCell = null;
      _isSelecting = false;
      _roundComplete = false;
    });
  }

  List<List<String>> _buildGrid(List<String> words) {
    for (int attempt = 0; attempt < 80; attempt++) {
      final List<List<String>> grid = List<List<String>>.generate(
        _gridSize,
        (_) => List<String>.filled(_gridSize, ''),
      );
      bool success = true;
      for (final String word in words) {
        if (!_placeWord(grid, word)) {
          success = false;
          break;
        }
      }
      if (!success) continue;
      _fillRandom(grid);
      return grid;
    }

    final List<List<String>> fallback = List<List<String>>.generate(
      _gridSize,
      (_) => List<String>.filled(_gridSize, ''),
    );
    _fillRandom(fallback);
    return fallback;
  }

  bool _placeWord(List<List<String>> grid, String word) {
    const List<Offset> directions = <Offset>[
      Offset(0, 1),
      Offset(1, 0),
      Offset(1, 1),
      Offset(1, -1),
    ];

    final String normalizedWord = _normalizeWord(word);

    for (int attempt = 0; attempt < 120; attempt++) {
      final Offset direction = directions[_random.nextInt(directions.length)];
      final int startRow = _random.nextInt(_gridSize);
      final int startCol = _random.nextInt(_gridSize);

      if (_canPlaceWord(
        grid,
        normalizedWord,
        startRow,
        startCol,
        direction.dy.toInt(),
        direction.dx.toInt(),
      )) {
        for (int index = 0; index < normalizedWord.length; index++) {
          final int row = startRow + (index * direction.dy.toInt());
          final int col = startCol + (index * direction.dx.toInt());
          grid[row][col] = normalizedWord[index];
        }
        return true;
      }
    }

    return false;
  }

  bool _canPlaceWord(
    List<List<String>> grid,
    String word,
    int startRow,
    int startCol,
    int dRow,
    int dCol,
  ) {
    for (int index = 0; index < word.length; index++) {
      final int row = startRow + (index * dRow);
      final int col = startCol + (index * dCol);

      if (row < 0 || row >= _gridSize || col < 0 || col >= _gridSize) {
        return false;
      }

      final String current = grid[row][col];
      if (current.isNotEmpty && current != word[index]) {
        return false;
      }
    }

    return true;
  }

  void _fillRandom(List<List<String>> grid) {
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        if (grid[row][col].isEmpty) {
          grid[row][col] = _letters[_random.nextInt(_letters.length)];
        }
      }
    }
  }

  String _normalizeWord(String value) {
    return value
        .toLowerCase()
        .replaceAllMapped(RegExp(r'[áàäâ]'), (_) => 'a')
        .replaceAllMapped(RegExp(r'[éèëê]'), (_) => 'e')
        .replaceAllMapped(RegExp(r'[íìïî]'), (_) => 'i')
        .replaceAllMapped(RegExp(r'[óòöô]'), (_) => 'o')
        .replaceAllMapped(RegExp(r'[úùüû]'), (_) => 'u')
        .replaceAllMapped(RegExp(r'[ñ]'), (_) => 'n')
        .replaceAll(RegExp(r'[^a-z]'), '');
  }

  _GridCell? _cellFromGlobal(Offset globalPosition) {
    final BuildContext? boardContext = _boardKey.currentContext;
    if (boardContext == null) return null;

    final RenderBox box = boardContext.findRenderObject()! as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);
    final double cellSize = box.size.width / _gridSize;
    final int row = (localPosition.dy / cellSize).floor();
    final int col = (localPosition.dx / cellSize).floor();

    if (row < 0 || row >= _gridSize || col < 0 || col >= _gridSize) {
      return null;
    }

    return _GridCell(row, col);
  }

  void _handlePointerDown(PointerDownEvent event) {
    final _GridCell? cell = _cellFromGlobal(event.position);
    if (cell == null) return;

    setState(() {
      _isSelecting = true;
      _startCell = cell;
      _selectedCells = <_GridCell>[cell];
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isSelecting || _startCell == null) return;
    final _GridCell? cell = _cellFromGlobal(event.position);
    if (cell == null) return;

    final List<_GridCell> nextSelection = _cellsInLine(_startCell!, cell);
    if (nextSelection.isEmpty) return;

    setState(() {
      _selectedCells = nextSelection;
    });
  }

  void _handlePointerUp(PointerEvent event) {
    if (!_isSelecting) return;
    _checkSelection();
  }

  List<_GridCell> _cellsInLine(_GridCell start, _GridCell end) {
    final int dRow = end.row - start.row;
    final int dCol = end.col - start.col;

    if (dRow == 0) {
      final int minCol = min(start.col, end.col);
      final int maxCol = max(start.col, end.col);
      return List<_GridCell>.generate(
        maxCol - minCol + 1,
        (int index) => _GridCell(start.row, minCol + index),
      );
    }

    if (dCol == 0) {
      final int minRow = min(start.row, end.row);
      final int maxRow = max(start.row, end.row);
      return List<_GridCell>.generate(
        maxRow - minRow + 1,
        (int index) => _GridCell(minRow + index, start.col),
      );
    }

    if (dRow.abs() == dCol.abs()) {
      final int steps = dRow.abs();
      final int rowStep = dRow > 0 ? 1 : -1;
      final int colStep = dCol > 0 ? 1 : -1;
      return List<_GridCell>.generate(
        steps + 1,
        (int index) => _GridCell(
          start.row + (index * rowStep),
          start.col + (index * colStep),
        ),
      );
    }

    return const <_GridCell>[];
  }

  void _checkSelection() {
    final List<_GridCell> selection = _selectedCells;
    final _GridCell? startCell = _startCell;

    setState(() {
      _isSelecting = false;
      _startCell = null;
    });

    if (selection.length < 3 || startCell == null) {
      setState(() {
        _selectedCells = const <_GridCell>[];
      });
      return;
    }

    final String selectedText = selection
        .map((cell) => _grid[cell.row][cell.col])
        .join();
    final String reversedText = selectedText.split('').reversed.join();

    String? foundWord;
    for (final String word in _words) {
      final String normalizedWord = _normalizeWord(word);
      if (selectedText == normalizedWord || reversedText == normalizedWord) {
        foundWord = word;
        break;
      }
    }

    if (foundWord != null && !_foundWords.contains(foundWord)) {
      setState(() {
        _foundWords.add(foundWord!);
        _foundCells.addAll(selection);
        _selectedCells = const <_GridCell>[];
        _roundComplete = _foundWords.length == _words.length;
      });
      return;
    }

    setState(() {
      _selectedCells = const <_GridCell>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.sizeOf(context).width < 768;

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: MeaningRichText(
              text: 'Cerca de parolas',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 24),
          _InstructionCard(mobile: mobile),
          const SizedBox(height: 24),
          _GameInfo(words: _words, foundWords: _foundWords, mobile: mobile),
          const SizedBox(height: 24),
          Center(child: _buildBoard()),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.center,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: <Widget>[
                if (_roundComplete)
                  FilledButton(
                    onPressed: _newRound,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Jocar un altere'),
                  ),
                OutlinedButton(
                  onPressed: _newRound,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textColor(context),
                    side: BorderSide(color: AppTheme.borderColor(context)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Reinitiar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          key: _boardKey,
          decoration: BoxDecoration(
            color: AppTheme.borderColor(context),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: Listener(
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerUp,
            onPointerCancel: _handlePointerUp,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gridSize,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: _gridSize * _gridSize,
              itemBuilder: (BuildContext context, int index) {
                final int row = index ~/ _gridSize;
                final int col = index % _gridSize;
                final _GridCell cell = _GridCell(row, col);
                final bool isSelected = _selectedCells.contains(cell);
                final bool isFound = _foundCells.contains(cell);

                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: isFound
                        ? const Color(0xFF28A745)
                        : isSelected
                        ? AppTheme.primary
                        : AppTheme.cardColor(context),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Text(
                          _grid[row][col],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isFound || isSelected
                                ? Colors.white
                                : AppTheme.textColor(context),
                          ),
                        ),
                      ),
                      if (isFound)
                        const Positioned(
                          top: 2,
                          right: 2,
                          child: Text(
                            '✓',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({required this.mobile});

  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MeaningRichText(
            text: 'Instructiones',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...<String>[
            'Trova le parolas occultate in le quadrato.',
            'Le parolas pote esser in horizontal, vertical o diagonal.',
            mobile
                ? 'Tocco e trahe pro seliger litteras.'
                : 'Clicca o trahe pro seliger litteras.',
            'Trova tote le parolas pro completar le ronda!',
          ].map(
            (String line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MeaningRichText(
                      text: line,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameInfo extends StatelessWidget {
  const _GameInfo({
    required this.words,
    required this.foundWords,
    required this.mobile,
  });

  final List<String> words;
  final Set<String> foundWords;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: words.map((String word) {
              final bool found = foundWords.contains(word);
              return _WordChip(word: word, found: found);
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _StatCard(value: foundWords.length.toString(), label: 'Trovate'),
              const SizedBox(width: 16),
              _StatCard(value: words.length.toString(), label: 'Total'),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: words.map((String word) {
              final bool found = foundWords.contains(word);
              return _WordChip(word: word, found: found);
            }).toList(),
          ),
        ),
        const SizedBox(width: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            _StatCard(value: foundWords.length.toString(), label: 'Trovate'),
            const SizedBox(width: 16),
            _StatCard(value: words.length.toString(), label: 'Total'),
          ],
        ),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({required this.word, required this.found});

  final String word;
  final bool found;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: found
            ? const Color(0xFFD4EDDA)
            : AppTheme.surfaceVariant(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: found
              ? const Color(0xFF28A745)
              : AppTheme.borderColor(context),
          width: 2,
        ),
      ),
      child: MeaningRichText(
        text: word,
        style: TextStyle(
          color: found ? const Color(0xFF155724) : AppTheme.textColor(context),
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          MeaningRichText(
            text: label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _GridCell {
  const _GridCell(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) {
    return other is _GridCell && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}
