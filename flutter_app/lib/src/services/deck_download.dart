import 'deck_download_stub.dart'
    if (dart.library.html) 'deck_download_web.dart'
    as impl;

Future<bool> downloadDeckFile({
  required String fileName,
  required String content,
}) {
  return impl.downloadDeckFile(fileName: fileName, content: content);
}
