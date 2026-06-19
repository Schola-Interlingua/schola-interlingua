import 'package:flutter/foundation.dart';

const String kNativeAuthScheme = 'scholainterlingua';
const String kNativeAuthHost = 'login-callback';
const String kNativeAuthRedirect = '$kNativeAuthScheme://$kNativeAuthHost';

String buildAuthRedirectUri(Uri baseUri) {
  if (kIsWeb) {
    return baseUri
        .removeFragment()
        .replace(queryParameters: <String, String>{'auth_callback': '1'})
        .toString();
  }

  return kNativeAuthRedirect;
}
