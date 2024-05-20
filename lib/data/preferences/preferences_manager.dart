// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:urven/data/models/user/user_profile.dart';
import 'package:urven/utils/primitive/string_utils.dart';

const String TAG = 'PreferencesManager';

class PreferencesManager {
  static const _KEY_LANGUAGE = 'language';
  static const _KEY_ACCESS_TOKEN = 'access_token';
  static const _KEY_USER_PROFILE = 'u_profile';

  // static const _KEY_USER_PROFILE = 'u_profile';

  late SharedPreferences pref;

  PreferencesManager._();

  static final instance = PreferencesManager._();

  Future init() async {
    pref = await SharedPreferences.getInstance();
  }

  String? getLanguageCode() => pref.getString(_KEY_LANGUAGE);

  Future<bool> saveLanguageCode(String languageCode) {
    return pref.setString(_KEY_LANGUAGE, languageCode);
  }

  void saveAuthCredentials(String accessToken) {
    pref.setString(_KEY_ACCESS_TOKEN, accessToken);
  }

  bool isAuthenticated() => getAccessToken().isNotNullOrBlank();

  String? getAccessToken() => pref.getString(_KEY_ACCESS_TOKEN);

  void saveUserProfile(UserProfile profile) {
    pref.setString(_KEY_USER_PROFILE, json.encode(profile));
  }

  void clearTokens() {
    pref.remove(_KEY_ACCESS_TOKEN);
  }

  void wipeOut() {
    pref.remove(_KEY_ACCESS_TOKEN);
    pref.remove(_KEY_USER_PROFILE);
  }



  UserProfile? getUserProfile() {
    String? profile = pref.getString(_KEY_USER_PROFILE);
    if (profile == null) return null;
    return UserProfile.fromJson(json.decode(profile));
  }
}
