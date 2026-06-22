import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../app_state.dart';
import '../services/anki_export_manifest.dart';
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
  _FooterLinkData(
    label: 'Terms',
    icon: Icons.description_outlined,
    url: 'https://www.scholainterlingua.com/terms',
  ),
  _FooterLinkData(
    label: 'Privacy',
    icon: Icons.privacy_tip_outlined,
    url: 'https://www.scholainterlingua.com/privacy',
  ),
  _FooterLinkData(
    label: 'Delete account',
    icon: Icons.person_remove_outlined,
    url: 'https://www.scholainterlingua.com/delete-account',
  ),
];

const String _aboutTitle = 'Benvenite a Schola Interlingua!';
const List<String> _aboutParagraphs = <String>[
  'Schola Interlingua es un platteforma digital disveloppate con le scopo de impulsar le apprension de Interlingua IALA. Con un stilo clar e moderne, nos offere lectiones structurate, vocabulario, explicationes del grammatica, e exercitios que te permitte apprender passo a passo e con confidentia.',
  'Nos crede in le fortia del saper collaborative, proque tote le material de Schola Interlingua es software libere e open source. Tu pote explorar, adaptar e compartir iste ressource sin restrictiones, e etiam contribuer al melioration continuate del sito.',
];

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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _exporting = false;
  bool _deletingAccount = false;
  AnkiExportManifest? _ankiManifest;
  String? _ankiManifestError;

  @override
  void initState() {
    super.initState();
    _loadAnkiManifest();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppStateScope.of(context).loadVocab();
  }

  Future<void> _loadAnkiManifest() async {
    try {
      final AnkiExportManifest manifest = await loadAnkiExportManifest();
      if (!mounted) return;
      setState(() {
        _ankiManifest = manifest;
        _ankiManifestError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _ankiManifestError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final _DeckPreview deckPreview = _buildDeckPreview(controller);
    final AnkiDeckAsset? deckAsset = _ankiManifest?.deckForLanguage(
      controller.selectedLanguage,
    );
    final String selectedLanguageLabel =
        _languageLabels[controller.selectedLanguage] ??
        controller.selectedLanguage;

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
              const SizedBox(height: 16),
              Text(
                '${deckAsset?.noteCount ?? deckPreview.cardsCount} cartas, ${deckPreview.levelCount} nivellos, ${deckPreview.sourceCount} gruppos de vocabulario',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (deckAsset != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'Dimension estimate: ${_formatBytes(deckAsset.sizeBytes)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (_ankiManifestError != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'Le manifesto del deck non pote esser cargate: $_ankiManifestError',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.red.shade300),
                ),
              ] else if (_ankiManifest != null && deckAsset == null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'Le package pro $selectedLanguageLabel non es ancora generate. Usa le script de generation ante publicar iste lingua.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed:
                    _exporting || deckAsset == null
                        ? null
                        : () => _exportDeck(context, deckAsset),
                child: Text(
                  _exporting
                      ? 'Preparante deck...'
                      : 'Discargar deck Anki (.apkg)',
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
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: controller.signOut,
                      child: const Text('Exir'),
                    ),
                    FilledButton.icon(
                      onPressed: _deletingAccount
                          ? null
                          : () => _confirmDeleteAccount(context, controller),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB83A3A),
                        foregroundColor: Colors.white,
                      ),
                      icon: _deletingAccount
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.delete_forever_rounded),
                      label: Text(
                        _deletingAccount ? 'Delente conto...' : 'Deler conto',
                      ),
                    ),
                  ],
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
    final Set<String> levels = <String>{};
    final Set<String> sources = <String>{};
    int cardsCount = 0;
    for (final card in controller.exportableCards) {
      final String back =
          (card.translations[controller.selectedLanguage] ??
                  card.translations['es'] ??
                  '')
              .trim();
      if (back.isEmpty) continue;
      cardsCount += 1;
      levels.add(card.levelTitle);
      sources.add(card.sourceTitle);
    }
    return _DeckPreview(
      cardsCount: cardsCount,
      levelCount: levels.length,
      sourceCount: sources.length,
    );
  }

  Future<void> _exportDeck(
    BuildContext context,
    AnkiDeckAsset deckAsset,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    setState(() {
      _exporting = true;
    });

    try {
      final ByteData packageData = await rootBundle.load(deckAsset.assetPath);
      final bool downloaded = await downloadDeckFile(
        fileName: deckAsset.file,
        bytes: packageData.buffer.asUint8List(
          packageData.offsetInBytes,
          packageData.lengthInBytes,
        ),
        mimeType: 'application/octet-stream',
      );

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            downloaded
                ? 'Deck descargate con successo.'
                : 'Iste platteforma non supporta ancora le descarga directe del `.apkg`.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Non pote preparar le deck: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 MB';
    final double sizeInMb = bytes / (1024 * 1024);
    return '${sizeInMb.toStringAsFixed(sizeInMb >= 100 ? 0 : 1)} MB';
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

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    AppController controller,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final GoRouter router = GoRouter.of(context);
    final String confirmationValue =
        controller.currentUser?.email?.trim() ?? 'DELER';
    final String confirmationLabel =
        controller.currentUser?.email?.trim().isNotEmpty == true
        ? 'tu email'
        : '"DELER"';
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: _dialogBarrierColor(context),
      builder: (BuildContext context) {
        return _DeleteAccountDialog(
          confirmationValue: confirmationValue,
          confirmationLabel: confirmationLabel,
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _deletingAccount = true;
    });

    try {
      await controller.deleteCurrentAccount();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Le conto esseva delite con successo.')),
      );
      router.go('/');
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Non pote deler le conto: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingAccount = false;
        });
      }
    }
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({
    required this.confirmationValue,
    required this.confirmationLabel,
  });

  final String confirmationValue;
  final String confirmationLabel;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  late final TextEditingController _confirmationController;

  bool get _matchesConfirmation =>
      _confirmationController.text.trim() == widget.confirmationValue;

  @override
  void initState() {
    super.initState();
    _confirmationController = TextEditingController();
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _dialogBackgroundColor(context),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: AppTheme.borderColor(context)),
      ),
      title: const Text('Deler conto?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Iste action es permanente. Le conto e le progresso synchronisate essera delite de Supabase.',
          ),
          const SizedBox(height: 16),
          Text(
            'Pro confirmar, scribe ${widget.confirmationLabel}.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmationController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(hintText: widget.confirmationValue),
          ),
        ],
      ),
      actions: <Widget>[
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancellar'),
        ),
        FilledButton(
          onPressed: _matchesConfirmation
              ? () => Navigator.of(context).pop(true)
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFB83A3A),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(
              0xFFB83A3A,
            ).withValues(alpha: 0.45),
            disabledForegroundColor: Colors.white70,
          ),
          child: const Text('Deler permanentemente'),
        ),
      ],
    );
  }
}

class _DeckPreview {
  const _DeckPreview({
    required this.cardsCount,
    required this.levelCount,
    required this.sourceCount,
  });

  final int cardsCount;
  final int levelCount;
  final int sourceCount;
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
