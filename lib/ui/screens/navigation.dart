// ignore_for_file: constant_identifier_names

import 'package:urven/ui/screens/code_input_screen.dart';
import 'package:urven/ui/screens/forgot_password.dart';
import 'package:urven/app.dart';

class Navigation {
  static const String INDEX = '/';
  static const String FORGOTPASSWORD = '/r_forgot_password';
  static const String CODEINPUT = '/r_code_input';

  static getIndex() {
    return Navigation.INDEX;
  }

  static getRoutes() {
    return {
      Navigation.INDEX: (context) => const UrvenApp(),
      Navigation.FORGOTPASSWORD: (context) => const ForgotPasswordScreen(),
      Navigation.CODEINPUT: (context) => const CodeInputScreen(),
    };
  }
}
