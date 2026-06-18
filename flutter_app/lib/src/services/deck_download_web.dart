// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;

Future<bool> downloadDeckFile({
  required String fileName,
  required String content,
}) async {
  final html.Blob blob = html.Blob(<List<int>>[
    utf8.encode(content),
  ], 'text/csv;charset=utf-8');
  final String url = html.Url.createObjectUrlFromBlob(blob);
  final html.AnchorElement anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
  return true;
}
