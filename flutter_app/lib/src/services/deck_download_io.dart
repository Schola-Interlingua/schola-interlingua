import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

Future<bool> downloadDeckFile({
  required String fileName,
  required String sourceUrl,
}) async {
  final Uri sourceUri = _withDownloadQuery(Uri.parse(sourceUrl), fileName);
  if (Platform.isAndroid || Platform.isIOS) {
    return launchUrl(sourceUri, mode: LaunchMode.externalApplication);
  }

  final Directory? downloadsDir = _downloadsDirectory();
  if (downloadsDir == null) {
    return launchUrl(sourceUri, mode: LaunchMode.externalApplication);
  }

  await downloadsDir.create(recursive: true);
  final File file = File('${downloadsDir.path}/$fileName');
  final HttpClient client = HttpClient();
  try {
    final HttpClientRequest request = await client.getUrl(sourceUri);
    final HttpClientResponse response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }
    final IOSink sink = file.openWrite();
    await response.pipe(sink);
    await sink.flush();
    await sink.close();
    return true;
  } finally {
    client.close(force: true);
  }
}

Uri _withDownloadQuery(Uri uri, String fileName) {
  return uri.replace(
    queryParameters: <String, String>{
      ...uri.queryParameters,
      'download': fileName,
    },
  );
}

Directory? _downloadsDirectory() {
  final Map<String, String> env = Platform.environment;
  if (Platform.isMacOS || Platform.isLinux) {
    final String? home = env['HOME'];
    if (home == null || home.isEmpty) return null;
    return Directory('$home/Downloads');
  }
  if (Platform.isWindows) {
    final String? profile = env['USERPROFILE'];
    if (profile == null || profile.isEmpty) return null;
    return Directory('$profile\\Downloads');
  }
  return null;
}
