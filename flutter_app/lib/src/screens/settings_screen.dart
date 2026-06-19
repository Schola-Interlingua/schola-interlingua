import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../data/course_seed.dart';
import '../models/course_models.dart';
import '../services/deck_download.dart';
import '../theme/app_theme.dart';

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

const List<_FooterLinkData> _footerLinks = <_FooterLinkData>[
  _FooterLinkData(
    label: 'Gruppetto',
    icon: Icons.forum_rounded,
    url: 'https://t.me/scholainterlingua',
  ),
  _FooterLinkData(
    label: 'Repositorio official',
    icon: Icons.code_rounded,
    url: 'https://github.com/Schola-Interlingua/schola-interlingua',
  ),
  _FooterLinkData(
    label: 'Plus materiales',
    icon: Icons.menu_book_rounded,
    url: 'https://github.com/arrunzo/interlingua-es',
  ),
  _FooterLinkData(
    label: 'Union Mundial pro Interlingua',
    icon: Icons.public_rounded,
    url: 'https://www.interlingua.com/interlingua-es/',
  ),
];

const String _aboutTitle = 'Benvenite a Schola Interlingua!';
const List<String> _aboutParagraphs = <String>[
  'Schola Interlingua es un platteforma digital disveloppate con le scopo de impulsar le apprension de Interlingua IALA. Con un stilo clar e moderne, nos offere lectiones structurate, vocabulario, explicationes del grammatica, e exercitios que te permitte apprender passo a passo e con confidentia.',
  'Nos crede in le fortia del saper collaborative, proque tote le material de Schola Interlingua es software libere e open source. Tu pote explorar, adaptar e compartir iste ressource sin restrictiones, e etiam contribuer al melioration continuate del sito.',
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Set<String> _selectedLevels;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _selectedLevels = courseLevels
        .map((CourseLevel level) => level.slug)
        .toSet();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppStateScope.of(context).loadVocab();
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final _DeckPreview deckPreview = _buildDeckPreview(controller);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ScholaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Configuration',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Linguas, apparentia e accesso del app.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ScholaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Deck Anki', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                'Discarga un deck con le vocabulario del curso pro le nivellos que tu selige, solo in ${_languageLabels[controller.selectedLanguage] ?? controller.selectedLanguage}.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: courseLevels.map((CourseLevel level) {
                  final bool selected = _selectedLevels.contains(level.slug);
                  return FilterChip(
                    label: Text(level.title),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        if (selected) {
                          _selectedLevels.remove(level.slug);
                        } else {
                          _selectedLevels.add(level.slug);
                        }
                      });
                    },
                    selectedColor: AppTheme.primary.withValues(alpha: 0.92),
                    checkmarkColor: Colors.white,
                    labelStyle: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(
                          color: selected
                              ? Colors.white
                              : AppTheme.textColor(context),
                        ),
                    backgroundColor: Colors.white.withValues(alpha: 0.10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppTheme.borderColor(context)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLevels
                          ..clear()
                          ..addAll(
                            courseLevels.map((CourseLevel level) => level.slug),
                          );
                      });
                    },
                    child: const Text('Tote le nivellos'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLevels.clear();
                      });
                    },
                    child: const Text('Nulle'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${deckPreview.cards.length} cartas preste a exportar',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _exporting || deckPreview.cards.isEmpty
                    ? null
                    : () => _exportDeck(context, controller, deckPreview),
                child: Text(
                  _exporting ? 'Preparante deck...' : 'Discargar deck Anki',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ScholaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Lingua', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _languageLabels.entries.map((
                  MapEntry<String, String> entry,
                ) {
                  final bool selected =
                      controller.selectedLanguage == entry.key;
                  return ChoiceChip(
                    label: Text(entry.value),
                    selected: selected,
                    onSelected: (_) =>
                        controller.setSelectedLanguage(entry.key),
                    labelStyle: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(
                          color: selected
                              ? Colors.white
                              : AppTheme.textColor(context),
                        ),
                    selectedColor: AppTheme.primary,
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppTheme.borderColor(context)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ScholaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Modo', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              SwitchListTile(
                value: controller.darkMode,
                onChanged: (_) => controller.toggleDarkMode(),
                contentPadding: EdgeInsets.zero,
                title: const Text('Modo obscur'),
                subtitle: const Text('Alterna inter modo clar e obscur.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ScholaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Accesso', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (controller.isAuthenticated) ...<Widget>[
                Text(
                  controller.currentUser?.email ?? 'Session aperte',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: controller.signOut,
                  child: const Text('Exir'),
                ),
              ] else ...<Widget>[
                Text(
                  'Tu pote usar le app sin entrar, o aperir session pro synchronisar progresso.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.go('/entrar'),
                  child: const Text('Entrar'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        ScholaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Schola Interlingua',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _showAboutDialog(context),
                icon: const Icon(Icons.info_outline_rounded),
                label: const Text('A proposito de Schola Interlingua'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ScholaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Ligamines', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _footerLinks
                    .map(
                      (_FooterLinkData link) => OutlinedButton.icon(
                        onPressed: () => _showLinkDialog(context, link),
                        icon: Icon(link.icon),
                        label: Text(link.label),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _DeckPreview _buildDeckPreview(AppController controller) {
    final Map<String, _DeckCard> uniqueCards = <String, _DeckCard>{};
    for (final card in controller.exportableCardsForLevels(_selectedLevels)) {
      final String back =
          (card.translations[controller.selectedLanguage] ??
                  card.translations['es'] ??
                  '')
              .trim();
      if (back.isEmpty) continue;
      final String key =
          '${card.term.toLowerCase()}|${back.toLowerCase()}|${card.levelSlug}';
      uniqueCards[key] = _DeckCard(
        front: card.term,
        back: back,
        levelTitle: card.levelTitle,
        sourceTitle: card.sourceTitle,
      );
    }

    final List<_DeckCard> cards = uniqueCards.values.toList()
      ..sort((a, b) {
        final int byLevel = a.levelTitle.compareTo(b.levelTitle);
        if (byLevel != 0) return byLevel;
        return a.front.compareTo(b.front);
      });

    final List<String> levelTitles = courseLevels
        .where((CourseLevel level) => _selectedLevels.contains(level.slug))
        .map((CourseLevel level) => level.title)
        .toList();

    return _DeckPreview(cards: cards, levelTitles: levelTitles);
  }

  Future<void> _exportDeck(
    BuildContext context,
    AppController controller,
    _DeckPreview preview,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    setState(() {
      _exporting = true;
    });

    final String csv = _buildCsv(preview.cards);
    final String fileName = _buildFileName(
      controller.selectedLanguage,
      preview,
    );
    final bool downloaded = await downloadDeckFile(
      fileName: fileName,
      content: csv,
    );

    if (!mounted) return;

    if (!downloaded) {
      await Clipboard.setData(ClipboardData(text: csv));
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          downloaded
              ? 'Deck descargate con successo.'
              : 'Le deck esseva copiate al area de transferentia pro importar lo manualmente.',
        ),
      ),
    );

    setState(() {
      _exporting = false;
    });
  }

  String _buildCsv(List<_DeckCard> cards) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Front,Back,Level,Source');
    for (final _DeckCard card in cards) {
      buffer.writeln(
        '${_csv(card.front)},${_csv(card.back)},${_csv(card.levelTitle)},${_csv(card.sourceTitle)}',
      );
    }
    return buffer.toString();
  }

  String _buildFileName(String language, _DeckPreview preview) {
    final String levels = preview.levelTitles.isEmpty
        ? 'vacue'
        : preview.levelTitles
              .map((String title) => title.toLowerCase().replaceAll(' ', '-'))
              .join('_');
    return 'schola-interlingua-$language-$levels.csv';
  }

  String _csv(String value) {
    final String escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  Future<void> _showAboutDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: _dialogBarrierColor(context),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _dialogBackgroundColor(context),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withValues(alpha: 0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: AppTheme.borderColor(context)),
          ),
          title: const Text(_aboutTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _aboutParagraphs
                  .map(
                    (String paragraph) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(paragraph),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Clauder'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLinkDialog(BuildContext context, _FooterLinkData link) {
    return showDialog<void>(
      context: context,
      barrierColor: _dialogBarrierColor(context),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _dialogBackgroundColor(context),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withValues(alpha: 0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: AppTheme.borderColor(context)),
          ),
          title: Text(link.label),
          content: SelectableText(link.url),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: link.url));
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ligamine copiate: ${link.label}')),
                );
              },
              child: const Text('Copiar ligamine'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Clauder'),
            ),
          ],
        );
      },
    );
  }

  Color _dialogBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF163154)
        : const Color(0xFFF6FAFF);
  }

  Color _dialogBarrierColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xB3121D2D)
        : const Color(0x8A0F2740);
  }
}

class _DeckPreview {
  const _DeckPreview({required this.cards, required this.levelTitles});

  final List<_DeckCard> cards;
  final List<String> levelTitles;
}

class _DeckCard {
  const _DeckCard({
    required this.front,
    required this.back,
    required this.levelTitle,
    required this.sourceTitle,
  });

  final String front;
  final String back;
  final String levelTitle;
  final String sourceTitle;
}

class _FooterLinkData {
  const _FooterLinkData({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final IconData icon;
  final String url;
}
