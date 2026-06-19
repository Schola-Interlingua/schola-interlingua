import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/course_models.dart';
import '../theme/app_theme.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key, required this.level});

  final CourseLevel level;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextButton.icon(
          onPressed: () => context.go('/course'),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Retornar al curso'),
        ),
        const SizedBox(height: 16),
        ScholaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                level.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Iste nivello continua disponibile como vista separate, ma le presentation principal del curso copia le pagina actual con tote le nivellos in un sol vista.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
