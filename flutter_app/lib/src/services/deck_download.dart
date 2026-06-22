import 'deck_download_stub.dart'
    if (dart.library.io) 'deck_download_io.dart'
    if (dart.library.html) 'deck_download_web.dart'
    as impl;

Future<bool> downloadDeckFile({
  required String fileName,
  required List<int> bytes,
  String mimeType = 'application/octet-stream',
}) {
  return impl.downloadDeckFile(
    fileName: fileName,
    bytes: bytes,
    mimeType: mimeType,
  );
}
