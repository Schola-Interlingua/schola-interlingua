import 'dart:io';

Future<bool> downloadDeckFile({
  required String fileName,
  required List<int> bytes,
  String mimeType = 'application/octet-stream',
}) async {
  final Directory? downloadsDir = _downloadsDirectory();
  if (downloadsDir == null) {
    return false;
  }

  await downloadsDir.create(recursive: true);
  final File file = File('${downloadsDir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return true;
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
