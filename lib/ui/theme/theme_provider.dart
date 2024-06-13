import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urven/ui/theme/palette.dart';

enum ThemeType { light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = _buildLightTheme();

  ThemeData get themeData => _themeData;

  ThemeType _themeType = ThemeType.light;

  ThemeType get themeType => _themeType;

  void setTheme(ThemeType themeType) {
    _themeType = themeType;
    _themeData = _themeType == ThemeType.light ? _buildLightTheme() : _buildDarkTheme();
    notifyListeners();
  }

  static ThemeData _buildLightTheme() {
    return ThemeData(
      primaryColor: Palette.MAIN,
      backgroundColor: Palette.BACKGROUND,
      scaffoldBackgroundColor: Palette.BACKGROUND,
      appBarTheme: AppBarTheme(
        backgroundColor: Palette.MAIN,
        elevation: 0, systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      // Define more light theme properties here
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      primaryColor: Palette.MAIN,
      backgroundColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: Palette.MAIN,
        elevation: 0, systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      // Define more dark theme properties here
    );
  }
}
