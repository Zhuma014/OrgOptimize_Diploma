// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:urven/data/models/user/user_profile.dart';

const String TAG = 'PreferencesManager';

class PreferencesManager {
  static const _KEY_LANGUAGE = 'language';
  static const _KEY_ACCESS_TOKEN = 'access_token';
  static const _KEY_USER_PROFILE = 'u_profile';
  static const _KEY_FCM_TOKEN = 'fcm_token';

  late SharedPreferences pref;

  PreferencesManager._();

  static final instance = PreferencesManager._();

  Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }

  String? getLanguageCode() => pref.getString(_KEY_LANGUAGE);

  Future<bool> saveLanguageCode(String languageCode) {
    return pref.setString(_KEY_LANGUAGE, languageCode);
  }

  Future<void> saveAuthCredentials(String accessToken) async {
    await pref.setString(_KEY_ACCESS_TOKEN, accessToken);
  }

  bool isAuthenticated() => getAccessToken()?.isNotEmpty ?? false;

  String? getAccessToken() => pref.getString(_KEY_ACCESS_TOKEN);

  Future<void> saveUserProfile(UserProfile profile) async {
    await pref.setString(_KEY_USER_PROFILE, json.encode(profile));
  }

  Future<void> clearTokens() async {
    await pref.remove(_KEY_ACCESS_TOKEN);
  }

  Future<void> wipeOut() async {
    await pref.remove(_KEY_ACCESS_TOKEN);
    await pref.remove(_KEY_USER_PROFILE);
  }

  UserProfile? getUserProfile() {
    String? profile = pref.getString(_KEY_USER_PROFILE);
    if (profile == null) return null;
    return UserProfile.fromJson(json.decode(profile));
  }

  Future<void> saveFirebaseMessagingToken(String token) async {
    await pref.setString(_KEY_FCM_TOKEN, token);
  }

  String? getFirebaseMessagingToken() => pref.getString(_KEY_FCM_TOKEN);
}
