import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/learning_practice.dart';
import '../services/learning_activity_catalog.dart';
import '../services/learning_practice_store.dart';
import '../theme/app_theme.dart';

class LearningPracticePanel extends StatefulWidget {
  const LearningPracticePanel({
    super.key,
    required this.slug,
    this.store,
    this.catalog,
    this.playAudio,
  });
  final String slug;
  final LearningPracticeStore? store;
  final Future<LearningActivityCatalog>? catalog;

  /// Allows device-independent tests; production plays the bundled asset.
  final Future<void> Function(String asset)? playAudio;
  @override
  State<LearningPracticePanel> createState() => _LearningPracticePanelState();
}

class _ExerciseState {
  final started = DateTime.now();
  final runId = DateTime.now().microsecondsSinceEpoch.toString();
  final support = <String>{};
  String input = '';
  String? feedback;
  bool solved = false;
  int plays = 0;
  int checks = 0;
}

class _LearningPracticePanelState extends State<LearningPracticePanel> {
  late Future<LearningActivityCatalog> _loading;
  late LearningPracticeStore _store;
  final _input = TextEditingController();
  final _states = <String, _ExerciseState>{};
  final _indices = <PracticeMode, int>{};
  Map<PracticeMode, List<LearningActivity>>? _round;
  PracticeMode? _mode;
  bool _busy = false;
  bool _playing = false;
  String? _error;
  AudioPlayer? _player;
  int _generation = 0;
  int _eventSerial = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _store = widget.store ?? LearningPracticeStore.instance;
    _loading = Future.wait([
      widget.catalog ?? LearningActivityCatalog.load(),
      _store.load(),
    ]).then((values) => values.first as LearningActivityCatalog);
  }

  @override
  void didUpdateWidget(covariant LearningPracticePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _generation++;
      unawaited(_player?.stop());
      _states.clear();
      _indices.clear();
      _round = null;
      _mode = null;
      _input.clear();
      _busy = false;
      _playing = false;
      _error = null;
      _load();
    }
  }

  @override
  void dispose() {
    _generation++;
    _input.dispose();
    unawaited(_player?.dispose());
    super.dispose();
  }

  void _prepare(LearningActivityCatalog catalog) {
    final lastSeen = <String, DateTime>{};
    for (final event in _store.forSource(widget.slug)) {
      lastSeen[event.activityId] = event.at;
    }
    _round = {
      for (final mode in PracticeMode.values)
        mode:
            (catalog.forSource(widget.slug, mode)..sort((a, b) {
                  final bySeen = (lastSeen[a.id] ?? DateTime(1970)).compareTo(
                    lastSeen[b.id] ?? DateTime(1970),
                  );
                  if (bySeen != 0) return bySeen;
                  // Short phrases first for listening, then single words and long phrases.
                  int rank(LearningActivity item) {
                    final words = item.answers.first.split(' ').length;
                    return words >= 3 && words <= 9
                        ? 0
                        : words < 3
                        ? 1
                        : 2;
                  }

                  final byRank = rank(a).compareTo(rank(b));
                  return byRank != 0 ? byRank : a.id.compareTo(b.id);
                }))
                .take(8)
                .toList(),
    };
    _mode ??= _round![PracticeMode.cloze]!.isNotEmpty
        ? PracticeMode.cloze
        : PracticeMode.dictation;
  }

  Future<void> _record(
    LearningActivity activity,
    _ExerciseState state,
    PracticeEventKind kind, {
    String? answer,
    bool? correct,
  }) async {
    final now = DateTime.now();
    await _store.append(
      PracticeEvent(
        id: '${now.microsecondsSinceEpoch}-${_eventSerial++}',
        runId: state.runId,
        activityId: activity.id,
        sourceSlug: widget.slug,
        mode: activity.mode,
        kind: kind,
        at: now,
        support: state.support.toList(),
        plays: state.plays,
        attemptNumber: state.checks,
        elapsedMs: now.difference(state.started).inMilliseconds,
        answer: answer,
        correct: correct,
      ),
    );
  }

  Future<void> _action(Future<void> Function() action) async {
    if (_busy || _playing) return;
    final generation = _generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(
          () => _error = 'Non pote salvar le practica local. Essaya de novo.',
        );
      }
    } finally {
      if (mounted && generation == _generation) setState(() => _busy = false);
    }
  }

  Future<void> _listen(LearningActivity activity, _ExerciseState state) async {
    if (_busy || _playing) return;
    final generation = _generation;
    setState(() {
      _playing = true;
      _error = null;
    });
    try {
      if (widget.playAudio != null) {
        await widget.playAudio!(activity.audioAsset!);
      } else {
        final player = _player ??= AudioPlayer();
        await player.setAsset(activity.audioAsset!);
        if (!mounted || generation != _generation) return;
        await player.seek(Duration.zero);
        await player.play();
      }
      if (!mounted || generation != _generation) return;
      state.plays++;
      if (state.plays > 1) state.support.add('replay');
      await _record(activity, state, PracticeEventKind.audio);
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(
          () => _error =
              'Non pote reproducer o registrar le audio. Essaya de novo.',
        );
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _playing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<LearningActivityCatalog>(
    future: _loading,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return ScholaCard(
          child: Column(
            children: [
              const Text('Non pote cargar le practica.'),
              TextButton(
                onPressed: () => setState(_load),
                child: const Text('Reprobar'),
              ),
            ],
          ),
        );
      }
      if (!snapshot.hasData) return const SizedBox.shrink();
      final catalog = snapshot.data!;
      if (_round == null) _prepare(catalog);
      if (_round!.values.every((items) => items.isEmpty)) {
        return const SizedBox.shrink();
      }
      final mode = _mode!;
      final activities = _round![mode]!;
      final index = _indices[mode] ?? 0;
      return ScholaCard(
        key: const Key('learning-practice-panel'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Practica in contexto',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final choice in PracticeMode.values)
                  if (_round![choice]!.isNotEmpty)
                    ChoiceChip(
                      key: ValueKey('practice-mode-${choice.name}'),
                      label: Text(
                        choice == PracticeMode.cloze
                            ? 'Completar phrases'
                            : 'Dictato',
                      ),
                      selected: mode == choice,
                      onSelected: _busy || _playing
                          ? null
                          : (_) => setState(() {
                              _mode = choice;
                              final list = _round![choice]!;
                              final nextIndex = _indices[choice] ?? 0;
                              _input.text = nextIndex < list.length
                                  ? (_states[list[nextIndex].id]?.input ?? '')
                                  : '';
                              _error = null;
                            }),
                    ),
              ],
            ),
            const SizedBox(height: 18),
            if (index >= activities.length) ...[
              const Text('Ben facite! Tu ha finite iste session.'),
              TextButton(
                onPressed: () => setState(() {
                  _states.clear();
                  _indices.clear();
                  _round = null;
                  _input.clear();
                  _prepare(catalog);
                }),
                child: const Text('Nove session'),
              ),
            ] else
              _exercise(activities[index], index, activities.length),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  key: const Key('practice-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );

  Widget _exercise(LearningActivity activity, int index, int total) {
    final state = _states.putIfAbsent(activity.id, _ExerciseState.new);
    final locked = _busy || _playing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Exercitio ${index + 1} / $total',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        Text(
          activity.prompt,
          key: const Key('practice-prompt'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (activity.mode == PracticeMode.dictation) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('practice-audio'),
            onPressed: locked ? null : () => _listen(activity, state),
            icon: Icon(
              _playing ? Icons.hourglass_top : Icons.volume_up_rounded,
            ),
            label: Text(
              _playing
                  ? 'Ascoltante…'
                  : state.plays == 0
                  ? 'Ascoltar'
                  : 'Reascoltar (${state.plays})',
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          key: const Key('practice-answer'),
          controller: _input,
          enabled: !state.solved && !locked,
          maxLength: 300,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          onChanged: (value) => state.input = value,
          decoration: InputDecoration(
            labelText: 'Scribe in Interlingua',
            counterText: '',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            if (!locked && !state.solved) _check(activity, state);
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              key: const Key('practice-check'),
              onPressed: locked || state.solved
                  ? null
                  : () => _check(activity, state),
              child: const Text('Verificar'),
            ),
            OutlinedButton(
              key: const Key('practice-hint'),
              onPressed:
                  locked ||
                      state.solved ||
                      state.support.contains('first-letter')
                  ? null
                  : () => _action(() async {
                      state.support.add('first-letter');
                      try {
                        await _record(activity, state, PracticeEventKind.hint);
                      } catch (_) {
                        state.support.remove('first-letter');
                        rethrow;
                      }
                    }),
              child: const Text('Indicio'),
            ),
            TextButton(
              key: const Key('practice-reveal'),
              onPressed: locked || state.solved
                  ? null
                  : () => _action(() async {
                      state.support.add('reveal');
                      await _record(activity, state, PracticeEventKind.reveal);
                      state.solved = true;
                      state.feedback =
                          'Responsa: ${activity.answers.first}. ${activity.explanation}';
                    }),
              child: const Text('Vider responsa'),
            ),
            TextButton(
              key: const Key('practice-next'),
              onPressed: locked
                  ? null
                  : () => setState(() {
                      _indices[activity.mode] = index + 1;
                      _input.clear();
                      _error = null;
                    }),
              child: const Text('Sequente'),
            ),
          ],
        ),
        if (state.support.contains('first-letter') && !state.solved)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Prime littera: ${activity.answers.first.substring(0, 1)}',
              key: const Key('practice-hint-text'),
            ),
          ),
        if (state.feedback != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Semantics(
              liveRegion: true,
              child: Text(state.feedback!, key: const Key('practice-feedback')),
            ),
          ),
      ],
    );
  }

  void _check(LearningActivity activity, _ExerciseState state) {
    if (_input.text.trim().isEmpty) {
      setState(() => _error = 'Scribe un responsa ante verificar.');
      return;
    }
    if (activity.mode == PracticeMode.dictation && state.plays == 0) {
      setState(() => _error = 'Ascolta le audio ante verificar.');
      return;
    }
    _action(() async {
      final answer = _input.text.trim();
      final correct = activity.accepts(answer);
      state.checks++;
      try {
        await _record(
          activity,
          state,
          PracticeEventKind.answer,
          answer: answer,
          correct: correct,
        );
      } catch (_) {
        state.checks--;
        rethrow;
      }
      state.solved = correct;
      state.feedback = correct
          ? '${state.support.isEmpty && state.checks == 1 ? "Correcte sin adjuta!" : "Correcte post practica o adjuta."} ${activity.explanation}'
          : 'Non ancora. Relege o reascolta e essaya de novo.';
      if (!correct) state.support.add('retry');
    });
  }
}
