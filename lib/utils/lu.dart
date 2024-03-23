// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LU {
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      AppLocalizations.localizationsDelegates;

  static const List<Locale> supportedLocales =
      AppLocalizations.supportedLocales;

  static const Locale defaultLocale = Locale('ru');

  static AppLocalizations of(BuildContext context) {
    AppLocalizations? appLocalizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    if (appLocalizations == null) {
      throw Exception('Localizations cannot be null!');
    }
    return appLocalizations;
  }
}
