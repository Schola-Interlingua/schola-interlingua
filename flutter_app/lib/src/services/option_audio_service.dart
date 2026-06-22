import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class OptionAudioService {
  OptionAudioService._();

  static final OptionAudioService instance = OptionAudioService._();

  static const String _audioBasePath = 'assets/audios/interlingua';

  final AudioPlayer _player = AudioPlayer();
  final Set<String> _missingAssets = <String>{};
  int _requestId = 0;

  static String normalizeOptionText(String text) {
    String normalized = text.trim().toLowerCase();
    const Map<String, String> replacements = <String, String>{
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'ã': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'ê': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'î': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'û': 'u',
      'ñ': 'n',
      'ç': 'c',
    };
    replacements.forEach((String from, String to) {
      normalized = normalized.replaceAll(from, to);
    });
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    normalized = normalized.replaceAll(RegExp(r'_+'), '_');
    return normalized.replaceAll(RegExp(r'^_|_$'), '');
  }

  static String? assetPathForOption(String optionText) {
    final String normalized = normalizeOptionText(optionText);
    if (normalized.isEmpty) return null;
    return '$_audioBasePath/$normalized.wav';
  }

  Future<void> playOptionAudio(String optionText) async {
    final String? assetPath = assetPathForOption(optionText);
    if (assetPath == null) {
      debugPrint('OptionAudioService: empty audio key for "$optionText".');
      return;
    }

    final int requestId = ++_requestId;
    try {
      await _player.stop();
      if (requestId != _requestId) return;
      await _player.setAsset(assetPath);
      if (requestId != _requestId) return;
      await _player.seek(Duration.zero);
      if (requestId != _requestId) return;
      await _player.play();
    } catch (error, stackTrace) {
      if (_missingAssets.add(assetPath)) {
        debugPrint(
          'OptionAudioService: failed to play "$optionText" from '
          '$assetPath: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }
}
