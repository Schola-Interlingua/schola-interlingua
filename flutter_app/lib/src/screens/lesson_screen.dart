import 'package:flutter/material.dart';

import '../data/web_content_loader.dart';
import '../models/web_content_models.dart';
import '../theme/app_theme.dart';
import '../widgets/completion_panel.dart';
import '../widgets/lesson_audio_player.dart';
import '../widgets/meaning_rich_text.dart';
import '../widgets/practice_panel.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final bool isLection = slug.startsWith('lection');
    if (!isLection) {
      return VocabLessonScreen(slug: slug);
    }

    return FutureBuilder<ParsedLectionContent?>(
      future: WebContentLoader.loadLection(slug),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<ParsedLectionContent?> snapshot,
          ) {
            final ParsedLectionContent? content = snapshot.data;
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _LoadErrorCard(
                message: 'Non pote cargar $slug.',
                detail: snapshot.error.toString(),
              );
            }
            if (content == null) {
              return _LoadErrorCard(
                message: 'Lection vacue: $slug',
                detail: 'Le contento non esseva disponibile.',
              );
            }

            final bool mobile = MediaQuery.sizeOf(context).width < 900;

            return CompletionTracker(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 4),
                  CompletionBanner(
                    itemKey: 'lesson:$slug',
                    message: 'Le lection es complete!',
                  ),
                  const SizedBox(height: 16),
                  ScholaCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        MeaningRichText(
                          text: content.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        if (content.audioAsset != null) ...<Widget>[
                          const SizedBox(height: 20),
                          LessonAudioPlayer(assetPath: content.audioAsset!),
                        ],
                        const SizedBox(height: 24),
                        mobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _LessonTextBlock(
                                    paragraphs: content.paragraphs,
                                  ),
                                  if (content.imageAsset != null) ...<Widget>[
                                    const SizedBox(height: 24),
                                    _LessonImage(
                                      imageAsset: content.imageAsset!,
                                    ),
                                  ],
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 680,
                                      ),
                                      child: _LessonTextBlock(
                                        paragraphs: content.paragraphs,
                                      ),
                                    ),
                                  ),
                                  if (content.imageAsset != null) ...<Widget>[
                                    const SizedBox(width: 32),
                                    Expanded(
                                      flex: 2,
                                      child: _LessonImage(
                                        imageAsset: content.imageAsset!,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PracticePanel(slug: slug),
                  if (content.grammarBullets.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 24),
                    ScholaCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MeaningRichText(
                            text: 'Grammatica',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ...content.grammarBullets.map(
                            (String bullet) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 7),
                                    child: Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: AppTheme.textColor(context),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: MeaningRichText(text: bullet),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  CompletionPanel(
                    itemKey: 'lesson:$slug',
                    buttonLabel: 'Refacer le lection',
                  ),
                ],
              ),
            );
          },
    );
  }
}

class _LoadErrorCard extends StatelessWidget {
  const _LoadErrorCard({required this.message, required this.detail});

  final String message;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(message, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          SelectableText(
            detail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mutedTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class VocabLessonScreen extends StatelessWidget {
  const VocabLessonScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ScholaCard(
          child: MeaningRichText(
            text: _titleFromSlug(slug),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 24),
        PracticePanel(slug: slug),
      ],
    );
  }

  String _titleFromSlug(String value) {
    return value
        .split('-')
        .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class _LessonTextBlock extends StatelessWidget {
  const _LessonTextBlock({required this.paragraphs});

  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs
          .map(
            (String paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MeaningRichText(text: paragraph),
            ),
          )
          .toList(),
    );
  }
}

class _LessonImage extends StatelessWidget {
  const _LessonImage({required this.imageAsset});

  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.borderColor(context)),
        boxShadow: AppTheme.glassShadow(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(imageAsset, fit: BoxFit.cover),
      ),
    );
  }
}
