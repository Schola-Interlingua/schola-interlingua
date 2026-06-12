import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

class ContentPlaceholderScreen extends StatelessWidget {
  const ContentPlaceholderScreen._({
    required this.title,
    required this.slug,
    required this.summary,
  });

  factory ContentPlaceholderScreen.lesson({required String slug}) {
    return ContentPlaceholderScreen._(
      title: 'Lection o vocabulario',
      slug: slug,
      summary:
          'Iste vista es le puncto de arrivo pro le migration de lectiones, vocabulario, practica, audio e progresso.',
    );
  }

  factory ContentPlaceholderScreen.reading({required String slug}) {
    return ContentPlaceholderScreen._(
      title: 'Lectura',
      slug: slug,
      summary:
          'Aqui venira le renderer de textos in Interlingua con consultation de significato per parola e accesso contextual a Chatina.',
    );
  }

  factory ContentPlaceholderScreen.appendix({required String slug}) {
    return ContentPlaceholderScreen._(
      title: 'Appendice',
      slug: slug,
      summary:
          'Iste vista servira pro grammatica, numeros e altere materiales editorial migrate al nove modelo structurate.',
    );
  }

  final String title;
  final String slug;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ScholaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text('Slug actual: $slug'),
              const SizedBox(height: 12),
              Text(summary),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  TextButton(
                    onPressed: () => context.go('/chat'),
                    child: const Text('Aperi Chatina'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/course'),
                    child: const Text('Retornar al curso'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
