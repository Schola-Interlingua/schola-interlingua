import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/lesson_grammar_topics.dart';
import '../theme/app_theme.dart';

/// The lesson's own explanations, with compact, selectable examples.
class LessonGrammar extends StatefulWidget {
  const LessonGrammar({
    super.key,
    required this.slug,
    this.bullets = const [],
    this.topics,
  });

  final String slug;
  final List<String> bullets;
  final List<LessonGrammarTopic>? topics;

  @override
  State<LessonGrammar> createState() => _LessonGrammarState();
}

class _LessonGrammarState extends State<LessonGrammar> {
  int _topic = 0;
  final Map<int, int> _examples = {};

  @override
  void didUpdateWidget(covariant LessonGrammar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _topic = 0;
      _examples.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topics = widget.topics ?? lessonGrammarTopics[widget.slug];
    if (topics == null || topics.isEmpty) {
      return ScholaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grammatica', style: Theme.of(context).textTheme.titleLarge),
            for (final bullet in widget.bullets)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(bullet),
              ),
          ],
        ),
      );
    }
    final topic = topics[_topic];
    final exampleIndex = _examples[_topic] ?? 0;
    final example = topic.examples[exampleIndex];
    final explanation =
        topic.explanation ??
        topic.bulletIndices
            .where((index) => index < widget.bullets.length)
            .map((index) => widget.bullets[index].replaceAll('**', ''))
            .join(' ');

    return ScholaCard(
      key: const Key('lesson-grammar-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Grammatica', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (topics.length > 1)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var index = 0; index < topics.length; index++)
                  _choice(
                    context,
                    topics[index].title,
                    _topic == index,
                    ValueKey('lesson-grammar-topic-$index'),
                    () => setState(() => _topic = index),
                  ),
              ],
            )
          else
            Text(topic.title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 14),
          Text(
            explanation,
            key: const Key('lesson-grammar-explanation'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tocca un exemplo:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var index = 0; index < topic.examples.length; index++)
                      _choice(
                        context,
                        topic.examples[index].label,
                        exampleIndex == index,
                        ValueKey('lesson-grammar-example-$index'),
                        () => setState(() => _examples[_topic] = index),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  example.before,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedTextColor(context),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: AppTheme.interactiveTextColor(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        example.after,
                        key: const Key('lesson-grammar-result'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.interactiveTextColor(context),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  example.note,
                  key: const Key('lesson-grammar-note'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (topic.source != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openSource(topic.source!),
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: Text('UMI · ${topic.sections ?? "Fonte official"}'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openSource(String source) async {
    try {
      if (await launchUrl(Uri.parse(source))) return;
    } catch (_) {
      // Keep the source readable when a platform cannot open the browser.
    }
    if (!mounted) return;
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

  Widget _choice(
    BuildContext context,
    String label,
    bool selected,
    Key key,
    VoidCallback onTap,
  ) => ChoiceChip(
    key: key,
    label: Text(label),
    selected: selected,
    selectedColor: AppTheme.primaryLight,
    backgroundColor: AppTheme.surfaceVariant(context),
    checkmarkColor: Colors.white,
    labelStyle: TextStyle(
      color: selected ? Colors.white : AppTheme.textColor(context),
    ),
    side: BorderSide(color: AppTheme.borderColor(context)),
    onSelected: (_) => onTap(),
  );
}
