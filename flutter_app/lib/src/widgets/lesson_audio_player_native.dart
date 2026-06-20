import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../theme/app_theme.dart';

class LessonAudioPlayer extends StatefulWidget {
  const LessonAudioPlayer({super.key, required this.assetPath});

  final String assetPath;

  @override
  State<LessonAudioPlayer> createState() => _LessonAudioPlayerState();
}

class _LessonAudioPlayerState extends State<LessonAudioPlayer> {
  late final AudioPlayer _player;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _load();
  }

  Future<void> _load() async {
    await _player.setAsset(widget.assetPath);
    if (mounted) {
      setState(() {
        _ready = true;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Row(
        children: <Widget>[
          StreamBuilder<bool>(
            stream: _player.playingStream,
            initialData: false,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              final bool playing = snapshot.data ?? false;
              return IconButton(
                onPressed: !_ready
                    ? null
                    : () async {
                        if (playing) {
                          await _player.pause();
                        } else {
                          await _player.play();
                        }
                      },
                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<Duration?>(
              stream: _player.durationStream,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<Duration?> durationSnapshot,
                  ) {
                    final Duration total =
                        durationSnapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration>(
                      stream: _player.positionStream,
                      initialData: Duration.zero,
                      builder:
                          (
                            BuildContext context,
                            AsyncSnapshot<Duration> positionSnapshot,
                          ) {
                            final Duration position =
                                positionSnapshot.data ?? Duration.zero;
                            final double max = total.inMilliseconds > 0
                                ? total.inMilliseconds.toDouble()
                                : 1;
                            final double value = position.inMilliseconds
                                .clamp(0, max.toInt())
                                .toDouble();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 6,
                                    activeTrackColor: dark
                                        ? const Color(0xFF68B5FF)
                                        : AppTheme.primaryLight,
                                    inactiveTrackColor: dark
                                        ? Colors.white.withValues(alpha: 0.10)
                                        : AppTheme.primary.withValues(
                                            alpha: 0.12,
                                          ),
                                    thumbColor: dark
                                        ? const Color(0xFF8FD0FF)
                                        : AppTheme.primary,
                                    overlayColor: dark
                                        ? const Color(
                                            0xFF8FD0FF,
                                          ).withValues(alpha: 0.18)
                                        : AppTheme.primary.withValues(
                                            alpha: 0.16,
                                          ),
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 12,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 22,
                                    ),
                                  ),
                                  child: Slider(
                                    value: value,
                                    max: max,
                                    onChanged: !_ready
                                        ? null
                                        : (double newValue) async {
                                            await _player.seek(
                                              Duration(
                                                milliseconds: newValue.round(),
                                              ),
                                            );
                                          },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    '${_format(position)} / ${_format(total)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            );
                          },
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }

  String _format(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
