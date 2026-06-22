import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatinaEmbed extends StatefulWidget {
  const ChatinaEmbed({super.key});

  @override
  State<ChatinaEmbed> createState() => _ChatinaEmbedState();
}

class _ChatinaEmbedState extends State<ChatinaEmbed> {
  late final WebViewController _controller;
  Timer? _fallbackTimer;
  bool _loaded = false;

  static const String _chatinaHtml = r'''
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: #ffffff;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }
    #status {
      position: fixed;
      inset: 0;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #46617f;
      font-size: 15px;
      font-weight: 500;
      pointer-events: none;
      z-index: 1;
    }
    #athena_fab_btn,
    button#athena_fab_btn {
      top: 18px !important;
      right: 18px !important;
      bottom: auto !important;
      left: auto !important;
      z-index: 9999 !important;
    }
  </style>
</head>
<body>
  <div id="status">Cargante Chatina...</div>
  <script>
    (function () {
      const jquerySrc = 'https://code.jquery.com/jquery-3.7.1.min.js';
      const chatinaSrc = 'https://ia.softwcloud.com/app/IA/chat_js/chat.js?type=mini&key=lnyghdrM5s7ixKFYr5q/u5FeWklsm25en5vAt5+fqknFt6Cnx1FYVlU=';
      let opened = false;

      function setStatus(text) {
        const node = document.getElementById('status');
        if (node) node.textContent = text;
      }

      function clearStatus() {
        const node = document.getElementById('status');
        if (node) node.remove();
      }

      function ensureScript(src, onLoad) {
        const existing = document.querySelector('script[src="' + src + '"]');
        if (existing) {
          if (onLoad) {
            if (existing.dataset.loaded === 'true') {
              onLoad();
            } else {
              existing.addEventListener('load', onLoad, { once: true });
            }
          }
          return;
        }

        const script = document.createElement('script');
        script.src = src;
        script.addEventListener('load', () => {
          script.dataset.loaded = 'true';
          if (onLoad) onLoad();
        }, { once: true });
        script.addEventListener('error', () => {
          setStatus('Non pote cargar Chatina.');
        }, { once: true });
        document.body.appendChild(script);
      }

      function placeFab(button) {
        const host = button.closest('div');
        [button, host].filter(Boolean).forEach((element) => {
          element.style.position = 'fixed';
          element.style.top = '18px';
          element.style.right = '18px';
          element.style.bottom = 'auto';
          element.style.left = 'auto';
          element.style.zIndex = '999999';
        });
      }

      function hideFab(button) {
        const host = button.closest('div');
        [button, host].filter(Boolean).forEach((element) => {
          element.style.opacity = '0';
          element.style.pointerEvents = 'none';
          element.style.visibility = 'hidden';
        });
      }

      function openChatina() {
        const button =
          document.getElementById('athena_fab_btn') ||
          document.querySelector('button[aria-label="Open support chat"]') ||
          document.querySelector('[id*="athena_fab"]');

        if (!button) return false;

        placeFab(button);
        hideFab(button);

        if (!opened) {
          opened = true;
          setStatus('Aperiente Chatina...');
          button.click();
        }

        const panelText = document.body.innerText || '';
        if (panelText.includes('Type your message') ||
            panelText.includes('Designed by softwcloud.com') ||
            panelText.includes('Salute! Io es Chatina')) {
          clearStatus();
        }

        return true;
      }

      function bootstrap() {
        ensureScript(jquerySrc, () => {
          ensureScript(chatinaSrc, () => {
            setStatus('Aperiente Chatina...');
            openChatina();
            const observer = new MutationObserver(() => {
              openChatina();
            });
            observer.observe(document.documentElement, {
              childList: true,
              subtree: true,
              attributes: true,
              attributeFilter: ['style', 'class']
            });
            window.addEventListener('resize', openChatina);
            setTimeout(openChatina, 400);
            setTimeout(openChatina, 1200);
            setTimeout(openChatina, 2500);
          });
        });
      }

      document.addEventListener('DOMContentLoaded', bootstrap);
      bootstrap();
    })();
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _loaded = true;
            });
          },
        ),
      )
      ..loadHtmlString(_chatinaHtml);

    _fallbackTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted || _loaded) return;
      setState(() {
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (!_loaded)
            const ColoredBox(
              color: Colors.white,
              child: Center(
                child: Text(
                  'Cargante Chatina...',
                  style: TextStyle(
                    color: Color(0xFF46617F),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
