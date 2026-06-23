// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

Future<bool> downloadDeckFile({
  required String fileName,
  required String sourceUrl,
}) async {
  final Uri uri = Uri.parse(sourceUrl);
  final Uri downloadUri = uri.replace(
    queryParameters: <String, String>{
      ...uri.queryParameters,
      'download': fileName,
    },
  );
  final html.AnchorElement anchor =
      html.AnchorElement(href: downloadUri.toString())
        ..download = fileName
        ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  return true;
}
