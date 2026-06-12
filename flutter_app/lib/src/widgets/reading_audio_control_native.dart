import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../theme/app_theme.dart';

class ReadingAudioControl extends StatefulWidget {
  const ReadingAudioControl({super.key, required this.text});

  final String text;

  @override
  State<ReadingAudioControl> createState() => _ReadingAudioControlState();
}

class _ReadingAudioControlState extends State<ReadingAudioControl> {
  late final FlutterTts _tts;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    try {
      await _tts.setLanguage('ia');
    } catch (_) {
      try {
        await _tts.setLanguage('it-IT');
      } catch (_) {}
    }
    _tts.setStartHandler(() {
      if (mounted) {
        setState(() => _speaking = true);
      }
    });
    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _speaking = false);
      }
    });
    _tts.setCancelHandler(() {
      if (mounted) {
        setState(() => _speaking = false);
      }
    });
    _tts.setErrorHandler((_) {
      if (mounted) {
        setState(() => _speaking = false);
      }
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleRead() async {
    if (_speaking) {
      await _tts.stop();
      return;
    }
    await _tts.speak(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              onPressed: _toggleRead,
              icon: Icon(
                _speaking
                    ? Icons.stop_circle_outlined
                    : Icons.volume_up_outlined,
                color: AppTheme.primary,
              ),
            ),
            Text(
              _speaking ? 'Stoppar lectura' : 'Leger texto',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
