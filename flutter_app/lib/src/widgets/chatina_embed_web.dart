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

  Timer? _scriptTimer;

  @override
  void initState() {
    super.initState();
    _registerView();
    _injectOriginalScript();
  }

  @override
  void dispose() {
    _scriptTimer?.cancel();
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
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.justifyContent = 'flex-start';

      final html.DivElement note = html.DivElement()
        ..text = 'Chatina original se carga como in le sito web.'
        ..style.fontFamily = 'sans-serif'
        ..style.fontSize = '15px'
        ..style.color = '#6b7f99';

      container.children.add(note);
      return container;
    });
  }

  void _injectOriginalScript() {
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
        });
        html.document.body?.append(jqueryScript);
        _jqueryInjected = true;
        return;
      }

      _appendChatinaScript();
    });
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

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 560,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
