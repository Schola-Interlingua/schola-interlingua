import 'package:flutter/material.dart';

import '../data/web_content_loader.dart';
import '../models/web_content_models.dart';
import '../theme/app_theme.dart';
import '../widgets/meaning_rich_text.dart';

class AppendixScreen extends StatelessWidget {
  const AppendixScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ParsedAppendixContent?>(
      future: WebContentLoader.loadAppendix(slug),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<ParsedAppendixContent?> snapshot,
          ) {
            final ParsedAppendixContent? content = snapshot.data;
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _AppendixErrorState(detail: snapshot.error.toString());
            }
            if (content == null) {
              return const _AppendixErrorState(
                detail: 'Le appendice non esseva disponibile.',
              );
            }

            return ScholaCard(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MeaningRichText(
                      text: content.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    ...content.sections.map(
                      (ParsedAppendixSection section) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.borderColor(context),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (section.title.isNotEmpty)
                                MeaningRichText(
                                  text: section.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              if (section.title.isNotEmpty)
                                const SizedBox(height: 12),
                              ...section.paragraphs.map(
                                (String paragraph) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: MeaningRichText(text: paragraph),
                                ),
                              ),
                              ...section.bullets.map(
                                (String bullet) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                      ),
                    ),
                  ],
                ),
            );
          },
    );
  }
}

class _AppendixErrorState extends StatelessWidget {
  const _AppendixErrorState({required this.detail});

  final String detail;

  @override
  Widget build(BuildContext context) {
    return ScholaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Non pote cargar iste pagina.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          SelectableText(
            detail,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mutedTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
