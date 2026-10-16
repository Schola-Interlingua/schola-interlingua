import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/grammar_lessons.dart';
import '../theme/app_theme.dart';

/// Session-only practice: grammar experiments do not change vocabulary SRS.
class GrammarWorkshop extends StatefulWidget {
  const GrammarWorkshop({super.key, this.lessons = grammarLessons});

  final List<GrammarLesson> lessons;

  @override
  State<GrammarWorkshop> createState() => _GrammarWorkshopState();
}

class _GrammarWorkshopState extends State<GrammarWorkshop> {
  int _topic = 0;
  final Map<String, int> _examples = {};
  final Map<String, int> _questions = {};
  final Map<String, int> _responses = {};

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lessons[_topic];
    final exampleIndex = _examples[lesson.id] ?? 0;
    final example = lesson.examples[exampleIndex];
    final questionIndex = _questions[lesson.id] ?? 0;
    final question = lesson.questions[questionIndex];
    final responseKey = '${lesson.id}:$questionIndex';
    final response = _responses[responseKey];
    final answered = response != null;
    final correct = response == question.answer;
    final completed = widget.lessons.fold<int>(
      0,
      (total, item) =>
          total +
          List.generate(item.questions.length, (index) => index)
              .where(
                (index) =>
                    _responses['${item.id}:$index'] ==
                    item.questions[index].answer,
              )
              .length,
    );
    final totalQuestions = widget.lessons.fold<int>(
      0,
      (sum, item) => sum + item.questions.length,
    );
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.lessons.length > 1)
          ScholaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 32,
                  color: AppTheme.interactiveTextColor(context),
                ),
                const SizedBox(height: 12),
                Text(
                  'Grammatica interactive',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Comprende le regula. Explora le exemplos. Practica con un explication.',
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.lessons.length} themas · $totalQuestions exercitios',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: completed / totalQuestions,
                  color: AppTheme.interactiveTextColor(context),
                  backgroundColor: AppTheme.borderColor(context),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completed / $totalQuestions correcte in iste session',
                  key: const Key('grammar-progress'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        if (widget.lessons.length > 1)
          Text(
            'Selige un thema',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        const SizedBox(height: 10),
        if (widget.lessons.length > 1)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < widget.lessons.length; index++)
                ChoiceChip(
                  key: ValueKey('grammar-topic-${widget.lessons[index].id}'),
                  label: Text('${index + 1}. ${widget.lessons[index].title}'),
                  selected: _topic == index,
                  selectedColor: AppTheme.primaryLight,
                  backgroundColor: AppTheme.surfaceVariant(context),
                  checkmarkColor: Colors.white,
                  side: BorderSide(color: AppTheme.borderColor(context)),
                  labelStyle: TextStyle(
                    color: _topic == index
                        ? Colors.white
                        : AppTheme.textColor(context),
                  ),
                  onSelected: (_) => setState(() => _topic = index),
                ),
            ],
          ),
        const SizedBox(height: 20),
        ScholaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                lesson.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                lesson.summary,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.mutedTextColor(context),
                ),
              ),
              const SizedBox(height: 18),
              Text(lesson.rule, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),
              Text(
                'Explora le regula',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var index = 0; index < lesson.examples.length; index++)
                    ChoiceChip(
                      key: ValueKey('grammar-example-${lesson.id}-$index'),
                      label: Text(lesson.examples[index].label),
                      selected: exampleIndex == index,
                      selectedColor: AppTheme.primaryLight,
                      backgroundColor: AppTheme.surfaceVariant(context),
                      checkmarkColor: Colors.white,
                      side: BorderSide(color: AppTheme.borderColor(context)),
                      labelStyle: TextStyle(
                        color: exampleIndex == index
                            ? Colors.white
                            : AppTheme.textColor(context),
                      ),
                      onSelected: (_) =>
                          setState(() => _examples[lesson.id] = index),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                key: const Key('grammar-transformation'),
                padding: EdgeInsets.all(compact ? 16 : 24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      example.before,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Icon(
                        Icons.south_rounded,
                        color: AppTheme.interactiveTextColor(context),
                      ),
                    ),
                    Text(
                      example.after,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppTheme.interactiveTextColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(example.note),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 20,
                    color: AppTheme.interactiveTextColor(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(lesson.caution)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Fonte: Grammatica de interlingua · UMI · ${lesson.sections}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _openSource(context, lesson.source),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Leger le fonte official'),
                ),
              ),
              if (lesson.id == 'articulos')
                _sourceButton(
                  context,
                  'Articulo indefinite · §§19–21',
                  'articulo-indefinite',
                ),
              if (lesson.id == 'tempores')
                _sourceButton(
                  context,
                  'Tempore passate · §102',
                  'tempore-passate',
                ),
              if (lesson.id == 'negation')
                _sourceButton(
                  context,
                  'Pronomines personal · §§62–63',
                  'pronomines-personal',
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ScholaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Practica · ${questionIndex + 1} / ${lesson.questions.length}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              Text(
                question.prompt,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              for (var index = 0; index < question.options.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    key: ValueKey('grammar-answer-$index'),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      minimumSize: const Size.fromHeight(48),
                      disabledForegroundColor: response == index
                          ? AppTheme.successBannerText(context)
                          : AppTheme.mutedTextColor(context),
                      disabledBackgroundColor: response == index
                          ? AppTheme.successBannerBackground(context)
                          : null,
                      backgroundColor: response == index
                          ? (correct
                                ? AppTheme.successBannerBackground(context)
                                : Theme.of(context).colorScheme.errorContainer)
                          : null,
                      foregroundColor: response == index
                          ? (correct
                                ? AppTheme.successBannerText(context)
                                : Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer)
                          : null,
                      side: BorderSide(
                        color: response == index
                            ? (correct
                                  ? AppTheme.successBannerBorder(context)
                                  : Theme.of(context).colorScheme.error)
                            : AppTheme.borderColor(context),
                      ),
                    ),
                    onPressed: correct
                        ? null
                        : () => setState(() => _responses[responseKey] = index),
                    child: Row(
                      children: [
                        if (response == index) ...[
                          Icon(
                            correct
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(child: Text(question.options[index])),
                      ],
                    ),
                  ),
                ),
              if (answered) ...[
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    '${correct ? 'Correcte!' : 'Non ancora. Essaya de novo.'} ${question.explanation}',
                    key: const Key('grammar-feedback'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (questionIndex > 0)
                    OutlinedButton.icon(
                      onPressed: () => setState(
                        () => _questions[lesson.id] = questionIndex - 1,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Precedente'),
                    ),
                  if (questionIndex < lesson.questions.length - 1)
                    FilledButton.icon(
                      key: const Key('grammar-next-question'),
                      onPressed: correct
                          ? () => setState(
                              () => _questions[lesson.id] = questionIndex + 1,
                            )
                          : null,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Sequente exercitio'),
                    )
                  else if (correct && _topic < widget.lessons.length - 1)
                    FilledButton.icon(
                      key: const Key('grammar-next-topic'),
                      onPressed: () => setState(() => _topic += 1),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Sequente thema'),
                    ),
                  TextButton(
                    onPressed: () => setState(() {
                      for (
                        var index = 0;
                        index < lesson.questions.length;
                        index++
                      ) {
                        _responses.remove('${lesson.id}:$index');
                      }
                      _questions[lesson.id] = 0;
                    }),
                    child: const Text('Refacer iste thema'),
                  ),
                ],
              ),
              if (completed == totalQuestions)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Semantics(
                    liveRegion: true,
                    child: const Text(
                      'Ben facite! Tu ha completate tote le exercitios de iste session.',
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Explicationes e exercitios original de Schola Interlingua, basate sur le grammatica publicate per le Union Mundial pro Interlingua.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _sourceButton(BuildContext context, String title, String page) =>
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => _openSource(
            context,
            'https://www.interlingua.com/grammatica/grammatica/$page/',
          ),
          icon: const Icon(Icons.open_in_new_rounded, size: 16),
          label: Text(title),
        ),
      );

  Future<void> _openSource(BuildContext context, String source) async {
    try {
      if (await launchUrl(Uri.parse(source))) return;
    } catch (_) {
      /* Offer a readable source when the platform cannot open it. */
    }
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fonte official'),
        content: SelectableText(source),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Clauder'),
          ),
        ],
      ),
    );
  }
}
