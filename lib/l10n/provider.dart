// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/cupertino.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/utils/lu.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> initialize() async {
    String? languageCode = PreferencesManager.instance.getLanguageCode();
    if (languageCode == null) {
      _locale = LU.defaultLocale;
    } else {
      _locale = Locale(languageCode);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    PreferencesManager.instance
        .saveLanguageCode(locale.languageCode)
        .then((value) {
      if (value) {
        _locale = locale;
        notifyListeners();
      }
    });
  }
}
