// ignore_for_file: constant_identifier_names
import 'package:urven/app.dart';
import 'package:urven/ui/screens/all_clubs.dart';
import 'package:urven/ui/screens/authentication_screen.dart';
import 'package:urven/ui/screens/my_clubs_screen.dart';
import 'package:urven/ui/screens/edit_profile_screen.dart';
import 'package:urven/ui/screens/profile_screen.dart';
import 'package:urven/ui/screens/settings_screen.dart';
import 'package:urven/wrapper.dart';

class Navigation {
  static const String INDEX = '/';
  static const String HOME = '/r_home';
  static const String AUTHENTICATION = '/r_authentication';
  static const String EDIT_USER_PROFILE = '/r_edit_profile';
  static const String SETTINGS = '/r_settings';
  static const String MYCLUBS = '/r_my_clubs';
  static const String ALLCLUBS = '/r_all_clubs';
  static const String PROFILE = '/r_profile';



  static getIndex() {
    return Navigation.INDEX;
  }

  static getRoutes() {
    return {
      Navigation.INDEX: (context) => const OrgOptimizeApp(),
      Navigation.HOME: (context) => const MainWrapper(),
      Navigation.AUTHENTICATION: (context) => const AuthenticationScreen(),
      Navigation.EDIT_USER_PROFILE: (context) => const EditProfileScreen(),
      Navigation.SETTINGS: (context) => const SettingsScreen(),
      Navigation.MYCLUBS: (context) =>  const MyClubsScreen(),
      Navigation.ALLCLUBS: (context) =>  const ClubsScreen(),
      Navigation.PROFILE: (context) =>  const UserProfileScreen(),



    };
  }
}
