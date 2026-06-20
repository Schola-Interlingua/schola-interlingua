import 'package:flutter/foundation.dart';

// Use a reverse-domain style scheme so the callback is unique on the device.
const String kNativeAuthScheme = 'com.scholainterlingua.app';
const String kNativeAuthHost = 'login-callback';
const String kNativeAuthRedirect = '$kNativeAuthScheme://$kNativeAuthHost/';

String buildAuthRedirectUri(Uri baseUri) {
  if (kIsWeb) {
    return baseUri
        .removeFragment()
        .replace(queryParameters: <String, String>{'auth_callback': '1'})
        .toString();
  }

  return kNativeAuthRedirect;
}
