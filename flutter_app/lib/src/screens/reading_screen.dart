import 'package:flutter/material.dart';

import '../data/web_content_loader.dart';
import '../models/web_content_models.dart';
import '../theme/app_theme.dart';
import '../widgets/completion_panel.dart';
import '../widgets/meaning_rich_text.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ParsedReadingContent?>(
      future: WebContentLoader.loadReading(slug),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<ParsedReadingContent?> snapshot,
          ) {
            final ParsedReadingContent? reading = snapshot.data;
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ReadingErrorState(detail: snapshot.error.toString());
            }
            if (reading == null) {
              return const _ReadingErrorState(
                detail: 'Le lectura non esseva disponibile.',
              );
            }

            final bool mobile = MediaQuery.sizeOf(context).width < 900;

            return CompletionTracker(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 4),
                  CompletionBanner(
                    itemKey: 'reading:$slug',
                    message: 'Le lectura es complete!',
                  ),
                  const SizedBox(height: 16),
                  ScholaCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        MeaningRichText(
                          text: reading.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),
                        mobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _ReadingBody(reading: reading),
                                  if (reading.imageAsset != null) ...<Widget>[
                                    const SizedBox(height: 24),
                                    _ReadingImage(
                                      imageAsset: reading.imageAsset!,
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
                                        maxWidth: 700,
                                      ),
                                      child: _ReadingBody(reading: reading),
                                    ),
                                  ),
                                  if (reading.imageAsset != null) ...<Widget>[
                                    const SizedBox(width: 32),
                                    Expanded(
                                      flex: 2,
                                      child: _ReadingImage(
                                        imageAsset: reading.imageAsset!,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CompletionPanel(
                    itemKey: 'reading:$slug',
                    buttonLabel: 'Refacer le lectura',
                  ),
                ],
              ),
            );
          },
    );
  }
}

class _ReadingErrorState extends StatelessWidget {
  const _ReadingErrorState({required this.detail});

  final String detail;

  @override
  Widget build(BuildContext context) {
    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Non pote cargar iste lectura.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
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

class _ReadingBody extends StatelessWidget {
  const _ReadingBody({required this.reading});

  final ParsedReadingContent reading;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reading.paragraphs
          .map(
            (String paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MeaningRichText(
                text: paragraph,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ReadingImage extends StatelessWidget {
  const _ReadingImage({required this.imageAsset});

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
