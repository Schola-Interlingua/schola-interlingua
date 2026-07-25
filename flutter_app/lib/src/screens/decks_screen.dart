import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../data/course_seed.dart';
import '../models/course_models.dart';
import '../models/deck_models.dart';
import '../services/exportable_vocab_catalog.dart';
import '../theme/app_theme.dart';
import 'srs_review_screen.dart';

enum DeckDetailKind { favorites, thematic, custom }

class DecksScreen extends StatefulWidget {
  const DecksScreen({super.key});

  @override
  State<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends State<DecksScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppStateScope.of(context).loadVocab();
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final List<_ThematicDeckData> thematicDecks = _buildThematicDecks(
      controller,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DecksHeader(onCreateDeck: () => _showCreateDeckDialog(context)),
        const SizedBox(height: 24),
        const _SectionHeading(
          title: 'Favoritos',
          subtitle: 'Le parolas que tu salva durante le studio.',
        ),
        const SizedBox(height: 12),
        _ResponsiveDeckGrid(
          children: <Widget>[
            _DeckCard(
              key: const Key('favorites-deck-card'),
              title: 'Parolas favorite',
              subtitle: controller.favoriteWords.isEmpty
                  ? 'Salva parolas ab le traduction.'
                  : 'Tu collection personal.',
              count: controller.favoriteWords.length,
              icon: Icons.favorite_rounded,
              accent: const Color(0xFFE54867),
              onTap: () => context.push('/decks/favorites'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _SectionHeading(
          title: 'Tu decks',
          subtitle: controller.customDecks.isEmpty
              ? 'Crea un deck e adde le parolas que tu vole practicar.'
              : 'Collectiones create per te.',
          action: TextButton.icon(
            key: const Key('create-deck-secondary'),
            onPressed: () => _showCreateDeckDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear'),
          ),
        ),
        const SizedBox(height: 12),
        if (controller.customDecks.isEmpty)
          _EmptyCustomDecks(onCreateDeck: () => _showCreateDeckDialog(context))
        else
          _ResponsiveDeckGrid(
            children: controller.customDecks.map((CustomDeck deck) {
              return _DeckCard(
                key: ValueKey<String>('custom-deck-${deck.id}'),
                title: deck.name,
                subtitle: 'Deck personal',
                count: deck.wordIds.length,
                icon: Icons.style_rounded,
                accent: const Color(0xFF6C8CFF),
                onTap: () => context.push('/decks/custom/${deck.id}'),
              );
            }).toList(),
          ),
        const SizedBox(height: 28),
        const _SectionHeading(
          title: 'Decks per thema',
          subtitle: 'Create automaticamente con le vocabulario del curso.',
        ),
        const SizedBox(height: 12),
        if (!controller.vocabLoaded)
          const ScholaCard(child: Center(child: CircularProgressIndicator()))
        else
          _ResponsiveDeckGrid(
            children: thematicDecks.map((_ThematicDeckData deck) {
              return _DeckCard(
                key: ValueKey<String>('theme-deck-${deck.slug}'),
                title: deck.title,
                subtitle: deck.levelTitle,
                count: deck.cards.length,
                icon: deck.icon,
                accent: AppTheme.primaryLight,
                onTap: () => context.push('/decks/theme/${deck.slug}'),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class DeckDetailScreen extends StatefulWidget {
  const DeckDetailScreen.favorites({super.key})
    : kind = DeckDetailKind.favorites,
      deckId = null;

  const DeckDetailScreen.thematic({super.key, required String slug})
    : kind = DeckDetailKind.thematic,
      deckId = slug;

  const DeckDetailScreen.custom({super.key, required this.deckId})
    : kind = DeckDetailKind.custom;

  final DeckDetailKind kind;
  final String? deckId;

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppStateScope.of(context).loadVocab();
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final _DeckDetailData? detail = _buildDetail(controller);
    if (detail == null) {
      return ScholaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Deck non trovate',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text('Iste deck non existe plus.'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go('/decks'),
              child: const Text('Retornar al decks'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DeckDetailHeader(
          detail: detail,
          onStartQuiz: detail.words.isEmpty
              ? null
              : () => context.push(_deckQuizRoute(widget.kind, widget.deckId)),
          onAddWords: widget.kind == DeckDetailKind.custom
              ? () => _showAddWordsDialog(context, widget.deckId!)
              : null,
          onDelete: widget.kind == DeckDetailKind.custom
              ? () => _confirmDelete(context, detail.title)
              : null,
        ),
        const SizedBox(height: 20),
        if (!controller.vocabLoaded)
          const ScholaCard(child: Center(child: CircularProgressIndicator()))
        else if (detail.words.isEmpty)
          _EmptyDeck(
            kind: widget.kind,
            onAddWords: widget.kind == DeckDetailKind.custom
                ? () => _showAddWordsDialog(context, widget.deckId!)
                : null,
          )
        else
          ScholaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: List<Widget>.generate(detail.words.length, (int index) {
                final _DeckWordData word = detail.words[index];
                return _DeckWordRow(
                  word: word,
                  isLast: index == detail.words.length - 1,
                  isFavorite: controller.isFavoriteWord(word.term),
                  onToggleFavorite: () {
                    controller.toggleFavoriteWord(word.term);
                  },
                  onRemove: widget.kind == DeckDetailKind.custom
                      ? () {
                          controller.removeWordFromCustomDeck(
                            widget.deckId!,
                            word.term,
                          );
                        }
                      : null,
                );
              }),
            ),
          ),
      ],
    );
  }

  _DeckDetailData? _buildDetail(AppController controller) {
    return _buildDeckDetail(controller, widget.kind, widget.deckId);
  }

  Future<void> _confirmDelete(BuildContext context, String deckName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: _deckDialogBackground(context),
          surfaceTintColor: Colors.transparent,
          shape: _deckDialogShape(context),
          title: const Text('Deler deck?'),
          content: Text(
            'Le deck “$deckName” essera delite. Le parolas favorite non essera afficite.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancellar'),
            ),
            FilledButton(
              key: const Key('confirm-delete-deck'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB83A3A),
              ),
              child: const Text('Deler'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    AppStateScope.of(context).deleteCustomDeck(widget.deckId!);
    context.go('/decks');
  }
}

class DeckQuizScreen extends StatefulWidget {
  const DeckQuizScreen.favorites({super.key})
    : kind = DeckDetailKind.favorites,
      deckId = null;

  const DeckQuizScreen.thematic({super.key, required String slug})
    : kind = DeckDetailKind.thematic,
      deckId = slug;

  const DeckQuizScreen.custom({super.key, required this.deckId})
    : kind = DeckDetailKind.custom;

  final DeckDetailKind kind;
  final String? deckId;

  @override
  State<DeckQuizScreen> createState() => _DeckQuizScreenState();
}

class _DeckQuizScreenState extends State<DeckQuizScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppStateScope.of(context).loadVocab();
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    if (!controller.vocabLoaded) {
      return const ScholaCard(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final _DeckDetailData? detail = _buildDeckDetail(
      controller,
      widget.kind,
      widget.deckId,
    );
    if (detail == null) {
      return ScholaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Deck non trovate',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/decks'),
              child: const Text('Retornar al decks'),
            ),
          ],
        ),
      );
    }

    final List<String> cardIds = controller.srsCardIdsForTerms(
      detail.words.map((_DeckWordData word) => word.term),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ScholaCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                onPressed: () =>
                    context.go(_deckDetailRoute(widget.kind, widget.deckId)),
                tooltip: 'Retornar al deck',
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 8),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: detail.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.quiz_rounded, color: detail.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Quiz rapide',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${detail.title} · ${cardIds.length} parolas · progresso SRS compartite',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mutedTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SrsReviewScreen(
          key: ValueKey<String>(
            'deck-quiz-${widget.kind.name}-${widget.deckId ?? 'favorites'}',
          ),
          cardIds: cardIds,
          title: 'Repaso del deck',
        ),
      ],
    );
  }
}

class _DecksHeader extends StatelessWidget {
  const _DecksHeader({required this.onCreateDeck});

  final VoidCallback onCreateDeck;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 620;
        return ScholaCard(
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _DecksHeaderCopy(onBack: () => context.go('/course')),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      key: const Key('create-deck-primary'),
                      onPressed: onCreateDeck,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Crear un deck'),
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    Expanded(
                      child: _DecksHeaderCopy(
                        onBack: () => context.go('/course'),
                      ),
                    ),
                    const SizedBox(width: 24),
                    FilledButton.icon(
                      key: const Key('create-deck-primary'),
                      onPressed: onCreateDeck,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Crear un deck'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _DecksHeaderCopy extends StatelessWidget {
  const _DecksHeaderCopy({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IconButton(
          onPressed: onBack,
          tooltip: 'Retornar a Studia',
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Decks de vocabulario',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Reuni parolas favorite, explora themas e crea tu proprie collectiones.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.mutedTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedTextColor(context),
                ),
              ),
            ],
          ),
        ),
        if (action != null) ...<Widget>[const SizedBox(width: 12), action!],
      ],
    );
  }
}

class _ResponsiveDeckGrid extends StatelessWidget {
  const _ResponsiveDeckGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double spacing = 14;
        final int columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final double width =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((Widget child) => SizedBox(width: width, child: child))
              .toList(),
        );
      },
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.borderColor(context)),
            boxShadow: AppTheme.glassShadow(context),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: accent.withValues(alpha: 0.48)),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$count parolas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.mutedTextColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCustomDecks extends StatelessWidget {
  const _EmptyCustomDecks({required this.onCreateDeck});

  final VoidCallback onCreateDeck;

  @override
  Widget build(BuildContext context) {
    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.style_outlined,
            size: 36,
            color: AppTheme.interactiveTextColor(context),
          ),
          const SizedBox(height: 12),
          Text(
            'Nulle deck create ancora',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea un deck personal e selige parolas del vocabulario del app.',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onCreateDeck,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear mi prime deck'),
          ),
        ],
      ),
    );
  }
}

class _DeckDetailHeader extends StatelessWidget {
  const _DeckDetailHeader({
    required this.detail,
    this.onStartQuiz,
    this.onAddWords,
    this.onDelete,
  });

  final _DeckDetailData detail;
  final VoidCallback? onStartQuiz;
  final VoidCallback? onAddWords;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 920;
        final Widget copy = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IconButton(
              onPressed: () => context.go('/decks'),
              tooltip: 'Retornar al decks',
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 8),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: detail.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(detail.icon, color: detail.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    detail.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${detail.subtitle} · ${detail.words.length} parolas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final Widget actions = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            if (onStartQuiz != null)
              FilledButton.icon(
                key: const Key('start-deck-quiz'),
                onPressed: onStartQuiz,
                icon: const Icon(Icons.quiz_rounded),
                label: const Text('Quiz rapide'),
              ),
            if (onAddWords != null)
              OutlinedButton.icon(
                key: const Key('add-words-to-deck'),
                onPressed: onAddWords,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Adder parolas'),
              ),
            if (onDelete != null)
              OutlinedButton.icon(
                key: const Key('delete-custom-deck'),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Deler deck'),
              ),
          ],
        );

        return ScholaCard(
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    copy,
                    if (onStartQuiz != null ||
                        onAddWords != null ||
                        onDelete != null) ...<Widget>[
                      const SizedBox(height: 18),
                      actions,
                    ],
                  ],
                )
              : Row(
                  children: <Widget>[
                    Expanded(child: copy),
                    if (onStartQuiz != null ||
                        onAddWords != null ||
                        onDelete != null) ...<Widget>[
                      const SizedBox(width: 20),
                      actions,
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _DeckWordRow extends StatelessWidget {
  const _DeckWordRow({
    required this.word,
    required this.isLast,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.onRemove,
  });

  final _DeckWordData word;
  final bool isLast;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppTheme.borderColor(context))),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  word.term,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  word.translation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: ValueKey<String>(
              'deck-favorite-${AppController.normalizeTerm(word.term)}',
            ),
            onPressed: onToggleFavorite,
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
          if (onRemove != null)
            IconButton(
              key: ValueKey<String>(
                'remove-deck-word-${AppController.normalizeTerm(word.term)}',
              ),
              onPressed: onRemove,
              tooltip: 'Retirar del deck',
              icon: const Icon(Icons.remove_circle_outline_rounded),
              color: AppTheme.mutedTextColor(context),
            ),
        ],
      ),
    );
  }
}

class _EmptyDeck extends StatelessWidget {
  const _EmptyDeck({required this.kind, this.onAddWords});

  final DeckDetailKind kind;
  final VoidCallback? onAddWords;

  @override
  Widget build(BuildContext context) {
    final String title;
    final String message;
    switch (kind) {
      case DeckDetailKind.favorites:
        title = 'Nulle parola favorite';
        message =
            'Tocca le icona de corde in le traduction de un parola pro salvar la hic.';
      case DeckDetailKind.custom:
        title = 'Iste deck es vacue';
        message = 'Adde parolas del vocabulario del app pro comenciar.';
      case DeckDetailKind.thematic:
        title = 'Nulle parola disponibile';
        message = 'Le vocabulario de iste thema non pote esser cargate.';
    }

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.inbox_outlined,
            size: 38,
            color: AppTheme.mutedTextColor(context),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message),
          if (onAddWords != null) ...<Widget>[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAddWords,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Adder parolas'),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddWordsDialog extends StatefulWidget {
  const _AddWordsDialog({required this.deckId});

  final String deckId;

  @override
  State<_AddWordsDialog> createState() => _AddWordsDialogState();
}

class _AddWordsDialogState extends State<_AddWordsDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final CustomDeck? deck = controller.customDeckById(widget.deckId);
    final Set<String> selectedWordIds = deck?.wordIds.toSet() ?? <String>{};
    final String normalizedQuery = _normalizeSearch(_query);
    final List<VocabularyWord> words = controller.vocabularyWords.where((
      VocabularyWord word,
    ) {
      if (normalizedQuery.isEmpty) return true;
      final String translation =
          controller.resolveMeaning(word.term, controller.selectedLanguage) ??
          '';
      return _normalizeSearch(word.term).contains(normalizedQuery) ||
          _normalizeSearch(translation).contains(normalizedQuery);
    }).toList();
    final Size size = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: _deckDialogBackground(context),
      surfaceTintColor: Colors.transparent,
      shape: _deckDialogShape(context),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: size.height * 0.86,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Adder parolas',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Clauder',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('add-words-search'),
                autofocus: true,
                onChanged: (String value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Cercar in Interlingua o in tu lingua...',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${selectedWordIds.length} parolas in le deck',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: words.isEmpty
                    ? const Center(
                        child: Text('Nulle parola coincide con le cerca.'),
                      )
                    : ListView.builder(
                        itemCount: words.length,
                        itemBuilder: (BuildContext context, int index) {
                          final VocabularyWord word = words[index];
                          final bool selected = selectedWordIds.contains(
                            word.id,
                          );
                          final String translation =
                              controller.resolveMeaning(
                                word.term,
                                controller.selectedLanguage,
                              ) ??
                              word.term;
                          return ListTile(
                            title: Text(word.term),
                            subtitle: Text(translation),
                            trailing: IconButton(
                              key: ValueKey<String>(
                                'toggle-deck-word-${word.id}',
                              ),
                              onPressed: () {
                                if (selected) {
                                  controller.removeWordFromCustomDeck(
                                    widget.deckId,
                                    word.term,
                                  );
                                } else {
                                  controller.addWordToCustomDeck(
                                    widget.deckId,
                                    word.term,
                                  );
                                }
                              },
                              tooltip: selected
                                  ? 'Retirar del deck'
                                  : 'Adder al deck',
                              icon: Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.add_circle_outline_rounded,
                                color: selected
                                    ? const Color(0xFF20C997)
                                    : AppTheme.interactiveTextColor(context),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showCreateDeckDialog(BuildContext context) async {
  final String? name = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => const _CreateDeckDialog(),
  );
  if (name == null || !context.mounted) return;
  final String deckId = AppStateScope.of(context).createCustomDeck(name);
  context.push('/decks/custom/$deckId');
}

class _CreateDeckDialog extends StatefulWidget {
  const _CreateDeckDialog();

  @override
  State<_CreateDeckDialog> createState() => _CreateDeckDialogState();
}

class _CreateDeckDialogState extends State<_CreateDeckDialog> {
  late final TextEditingController _nameController;

  bool get _canCreate => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canCreate) return;
    Navigator.of(context).pop(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _deckDialogBackground(context),
      surfaceTintColor: Colors.transparent,
      shape: _deckDialogShape(context),
      title: const Text('Crear un deck'),
      content: TextField(
        key: const Key('new-deck-name'),
        controller: _nameController,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(
          labelText: 'Nomine del deck',
          hintText: 'Exemplo: Parolas pro viagiar',
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancellar'),
        ),
        FilledButton(
          key: const Key('confirm-create-deck'),
          onPressed: _canCreate ? _submit : null,
          child: const Text('Crear'),
        ),
      ],
    );
  }
}

Future<void> _showAddWordsDialog(BuildContext context, String deckId) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) => _AddWordsDialog(deckId: deckId),
  );
}

_DeckDetailData? _buildDeckDetail(
  AppController controller,
  DeckDetailKind kind,
  String? deckId,
) {
  switch (kind) {
    case DeckDetailKind.favorites:
      return _DeckDetailData(
        title: 'Parolas favorite',
        subtitle: 'Tu collection personal',
        icon: Icons.favorite_rounded,
        accent: const Color(0xFFE54867),
        words: controller.favoriteWords
            .map(
              (VocabularyWord word) => _DeckWordData(
                term: word.term,
                translation:
                    controller.resolveMeaning(
                      word.term,
                      controller.selectedLanguage,
                    ) ??
                    word.term,
              ),
            )
            .toList(),
      );
    case DeckDetailKind.thematic:
      if (deckId == null) return null;
      final _ThematicDeckData? deck = _thematicDeckForSlug(controller, deckId);
      if (deck == null) return null;
      return _DeckDetailData(
        title: deck.title,
        subtitle: deck.levelTitle,
        icon: deck.icon,
        accent: AppTheme.primaryLight,
        words: deck.cards.map((ExportableVocabCard card) {
          return _DeckWordData(
            term: card.term,
            translation:
                card.translations[controller.selectedLanguage] ??
                card.translations['es'] ??
                controller.resolveMeaning(
                  card.term,
                  controller.selectedLanguage,
                ) ??
                card.term,
          );
        }).toList(),
      );
    case DeckDetailKind.custom:
      if (deckId == null) return null;
      final CustomDeck? deck = controller.customDeckById(deckId);
      if (deck == null) return null;
      return _DeckDetailData(
        title: deck.name,
        subtitle: 'Deck personal',
        icon: Icons.style_rounded,
        accent: const Color(0xFF6C8CFF),
        words: controller
            .wordsForCustomDeck(deck.id)
            .map(
              (VocabularyWord word) => _DeckWordData(
                term: word.term,
                translation:
                    controller.resolveMeaning(
                      word.term,
                      controller.selectedLanguage,
                    ) ??
                    word.term,
              ),
            )
            .toList(),
      );
  }
}

String _deckDetailRoute(DeckDetailKind kind, String? deckId) {
  return switch (kind) {
    DeckDetailKind.favorites => '/decks/favorites',
    DeckDetailKind.thematic => '/decks/theme/$deckId',
    DeckDetailKind.custom => '/decks/custom/$deckId',
  };
}

String _deckQuizRoute(DeckDetailKind kind, String? deckId) {
  return '${_deckDetailRoute(kind, deckId)}/quiz';
}

List<_ThematicDeckData> _buildThematicDecks(AppController controller) {
  final List<_ThematicDeckData> decks = <_ThematicDeckData>[];
  for (final CourseLevel level in courseLevels) {
    for (final CourseSection section in level.sections) {
      for (final CourseItemRef item in section.items) {
        if (item.kind != CourseItemKind.vocabulary) continue;
        final List<ExportableVocabCard> cards = controller
            .exportableCardsForSlug(item.slug);
        if (cards.isEmpty) continue;
        decks.add(
          _ThematicDeckData(
            slug: item.slug,
            title: item.title,
            levelTitle: level.title,
            icon: item.icon,
            cards: cards,
          ),
        );
      }
    }
  }
  return decks;
}

_ThematicDeckData? _thematicDeckForSlug(AppController controller, String slug) {
  for (final _ThematicDeckData deck in _buildThematicDecks(controller)) {
    if (deck.slug == slug) return deck;
  }
  return null;
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
      .trim();
}

Color _deckDialogBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF102640)
      : const Color(0xFFF6FAFF);
}

ShapeBorder _deckDialogShape(BuildContext context) {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(26),
    side: BorderSide(color: AppTheme.borderColor(context)),
  );
}

class _ThematicDeckData {
  const _ThematicDeckData({
    required this.slug,
    required this.title,
    required this.levelTitle,
    required this.icon,
    required this.cards,
  });

  final String slug;
  final String title;
  final String levelTitle;
  final IconData icon;
  final List<ExportableVocabCard> cards;
}

class _DeckDetailData {
  const _DeckDetailData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.words,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<_DeckWordData> words;
}

class _DeckWordData {
  const _DeckWordData({required this.term, required this.translation});

  final String term;
  final String translation;
}
