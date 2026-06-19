// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LessonAudioPlayer extends StatefulWidget {
  const LessonAudioPlayer({super.key, required this.assetPath});

  final String assetPath;

  @override
  State<LessonAudioPlayer> createState() => _LessonAudioPlayerState();
}

class _LessonAudioPlayerState extends State<LessonAudioPlayer> {
  static final Set<String> _registeredViewTypes = <String>{};

  late final String _viewType;
  late final String _resolvedAudioSrc;

  @override
  void initState() {
    super.initState();
    _resolvedAudioSrc = Uri.base
        .resolve('assets/${widget.assetPath}')
        .toString();
    _viewType =
        'lesson-audio-${widget.assetPath.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-')}';
    if (_registeredViewTypes.add(_viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final html.AudioElement audio = html.AudioElement()
          ..controls = true
          ..preload = 'metadata'
          ..src = _resolvedAudioSrc
          ..style.width = '100%'
          ..style.height = '44px'
          ..style.borderRadius = '14px'
          ..style.backgroundColor = 'transparent';
        return audio;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: SizedBox(height: 48, child: HtmlElementView(viewType: _viewType)),
    );
  }
}
