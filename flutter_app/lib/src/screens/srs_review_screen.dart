import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/srs_models.dart';
import '../services/exportable_vocab_catalog.dart';
import '../services/option_audio_service.dart';
import '../theme/app_theme.dart';

class SrsReviewScreen extends StatefulWidget {
  const SrsReviewScreen({super.key});

  @override
  State<SrsReviewScreen> createState() => _SrsReviewScreenState();
}

class _SrsReviewScreenState extends State<SrsReviewScreen> {
  final Random _random = Random();
  int _index = 0;
  int _correctAnswers = 0;
  String? _selectedChoice;
  List<String> _choices = const <String>[];
  bool _showSummary = false;
  List<String> _sessionCardIds = const <String>[];

  @override
  Widget build(BuildContext context) {
    final AppController controller = AppStateScope.of(context);
    final List<SrsCardProgress> dueProgress = controller.dueSrsProgress;
    if (_sessionCardIds.isEmpty && dueProgress.isNotEmpty) {
      _sessionCardIds = dueProgress
          .map((SrsCardProgress progress) => progress.cardId)
          .toList();
    }

    if (dueProgress.isEmpty) {
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
              'Non ha parolas debite pro hodie. Bon obra.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    if (_showSummary || _index >= _sessionCardIds.length) {
      return ScholaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Session finite',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Tu respondeva $_correctAnswers de ${_sessionCardIds.length} correctemente.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                setState(() {
                  _index = 0;
                  _correctAnswers = 0;
                  _selectedChoice = null;
                  _showSummary = false;
                  _choices = const <String>[];
                  _sessionCardIds = controller.dueSrsProgress
                      .map((SrsCardProgress progress) => progress.cardId)
                      .toList();
                });
              },
              child: const Text('Recomenciar'),
            ),
          ],
        ),
      );
    }

    final String currentCardId = _sessionCardIds[_index];
    final ExportableVocabCard? currentCard = controller.exportableCardById(
      currentCardId,
    );
    if (currentCard == null) {
      return const SizedBox.shrink();
    }

    final String language = controller.selectedLanguage;
    final String prompt =
        currentCard.translations[language] ??
        currentCard.translations['es'] ??
        currentCard.term;
    final String correctChoice = currentCard.term;

    if (_choices.isEmpty) {
      _choices = _buildChoices(controller.exportableCards, currentCard);
    }

    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Repaso rapide', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Carta ${_index + 1} de ${_sessionCardIds.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Text(
            prompt,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          ..._choices.map((String choice) {
            final bool selected = _selectedChoice == choice;
            final bool isCorrect = choice == correctChoice;
            Color background = AppTheme.cardColor(context);
            Color border = AppTheme.borderColor(context);
            Color foreground = AppTheme.textColor(context);
            if (_selectedChoice != null) {
              if (isCorrect) {
                background = const Color(0xFFD4EDDA);
                border = const Color(0xFF198754);
                foreground = const Color(0xFF155724);
              } else if (selected) {
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
                  onPressed: _selectedChoice != null
                      ? null
                      : () => _handleChoice(
                          controller: controller,
                          card: currentCard,
                          choice: choice,
                          correctChoice: correctChoice,
                        ),
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
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: foreground),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<String> _buildChoices(
    List<ExportableVocabCard> allCards,
    ExportableVocabCard currentCard,
  ) {
    final List<String> distractors =
        allCards
            .where((ExportableVocabCard card) => card.id != currentCard.id)
            .map((ExportableVocabCard card) => card.term)
            .toList()
          ..shuffle(_random);
    return <String>[currentCard.term, ...distractors.take(3)]..shuffle(_random);
  }

  void _handleChoice({
    required AppController controller,
    required ExportableVocabCard card,
    required String choice,
    required String correctChoice,
  }) {
    unawaited(OptionAudioService.instance.playOptionAudio(choice));
    final bool success = choice == correctChoice;
    controller.recordSrsReview(card.id, success: success);
    if (success) {
      _correctAnswers += 1;
    }
    setState(() {
      _selectedChoice = choice;
    });
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _index += 1;
        _selectedChoice = null;
        _choices = const <String>[];
        if (_index >= _sessionCardIds.length) {
          _showSummary = true;
        }
      });
    });
  }
}
