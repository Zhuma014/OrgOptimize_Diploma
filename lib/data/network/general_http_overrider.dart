import 'dart:io';

// Helps to skip the problem of SSL certification and solve the Image.network(url) issue
class GeneralHttpOverrider extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
