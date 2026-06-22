// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class ChatinaEmbed extends StatefulWidget {
  const ChatinaEmbed({super.key});

  @override
  State<ChatinaEmbed> createState() => _ChatinaEmbedState();
}

class _ChatinaEmbedState extends State<ChatinaEmbed> {
  static const String _jquerySrc =
      'https://code.jquery.com/jquery-3.7.1.min.js';
  static const String _chatinaSrc =
      'https://ia.softwcloud.com/app/IA/chat_js/chat.js?type=mini&key=lnyghdrM5s7ixKFYr5q/u5FeWklsm25en5vAt5+fqknFt6Cnx1FYVlU=';
  static const String _viewType = 'schola-chatina-original';
  static bool _registered = false;
  static bool _jqueryInjected = false;
  static bool _scriptInjected = false;
  static bool _styleInjected = false;

  Timer? _scriptTimer;
  Timer? _openTimer;

  @override
  void initState() {
    super.initState();
    _registerView();
    _injectOriginalScript();
  }

  @override
  void dispose() {
    _scriptTimer?.cancel();
    _openTimer?.cancel();
    super.dispose();
  }

  void _registerView() {
    if (_registered) return;
    _registered = true;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final html.DivElement container = html.DivElement()
        ..id = 'chatina-home-host'
        ..style.width = '100%'
        ..style.height = '560px'
        ..style.minHeight = '560px'
        ..style.display = 'block';
      return container;
    });
  }

  void _injectOriginalScript() {
    _ensureHideLauncherStyle();
    if (html.document.querySelector('script[src="$_jquerySrc"]') != null) {
      _jqueryInjected = true;
    }
    if (html.document.querySelector('script[src="$_chatinaSrc"]') != null) {
      _scriptInjected = true;
    }
    if (_scriptInjected) {
      return;
    }

    _scriptTimer = Timer(const Duration(milliseconds: 150), () {
      if (!_jqueryInjected) {
        final html.ScriptElement jqueryScript = html.ScriptElement()
          ..src = _jquerySrc;
        jqueryScript.onLoad.first.then((_) {
          _jqueryInjected = true;
          _appendChatinaScript();
          _scheduleOpen();
        });
        html.document.body?.append(jqueryScript);
        _jqueryInjected = true;
        return;
      }

      _appendChatinaScript();
      _scheduleOpen();
    });
  }

  void _ensureHideLauncherStyle() {
    if (_styleInjected) return;
    if (html.document.getElementById('schola-chatina-hide-style') != null) {
      _styleInjected = true;
      return;
    }
    final html.StyleElement style = html.StyleElement()
      ..id = 'schola-chatina-hide-style'
      ..text = '''
#athena_fab_btn,
button#athena_fab_btn,
[id*="athena_fab"] {
  opacity: 0 !important;
  pointer-events: none !important;
  visibility: hidden !important;
}
''';
    html.document.head?.append(style);
    _styleInjected = true;
  }

  void _appendChatinaScript() {
    if (_scriptInjected ||
        html.document.querySelector('script[src="$_chatinaSrc"]') != null) {
      _scriptInjected = true;
      return;
    }

    final html.ScriptElement script = html.ScriptElement()..src = _chatinaSrc;
    html.document.body?.append(script);
    _scriptInjected = true;
  }

  void _scheduleOpen() {
    _openTimer?.cancel();
    _openTimer = Timer.periodic(const Duration(milliseconds: 700), (Timer timer) {
      if (_openChatinaAndHideLauncher()) {
        timer.cancel();
      }
    });
  }

  bool _openChatinaAndHideLauncher() {
    final html.Element? button =
        html.document.getElementById('athena_fab_btn') ??
        html.document.querySelector('button[aria-label="Open support chat"]') ??
        html.document.querySelector('[id*="athena_fab"]');

    if (button == null) return false;

    final html.HtmlElement htmlButton = button as html.HtmlElement;
    htmlButton.style.opacity = '0';
    htmlButton.style.pointerEvents = 'none';
    htmlButton.style.visibility = 'hidden';

    final String pageText = html.document.body?.text ?? '';
    final bool alreadyOpen =
        pageText.contains('Type your message') ||
        pageText.contains('Designed by softwcloud.com') ||
        pageText.contains('Salute! Io es Chatina');
    if (!alreadyOpen) {
      htmlButton.click();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 560,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
