// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:urven/app.dart';
import 'package:urven/data/bloc/org_optimize_bloc.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/ui/screens/base/base_screen.dart';
import 'package:urven/ui/screens/navigation.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/profile_menu_option.dart';
import 'package:urven/ui/widgets/toolbar.dart';
import 'package:urven/utils/common_dialog.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends BaseScreenState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (!PreferencesManager.instance.isAuthenticated()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.BACKGROUND,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: SSC.p10),
                child: Toolbar(
                    isBackButtonVisible: false, title: LU.of(context).profile),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: SSC.p14, vertical: SSC.p8),
                child: Column(
                  children: [
                    _buildProfileOption(
                      context,
                      icon: Icons.person,
                      title: LU.of(context).personal_data,
                      onPressed: () {
                        Navigator.pushNamed(
                            context, Navigation.EDIT_USER_PROFILE);
                      },
                    ),
                    const Divider(),
                    _buildProfileOption(
                      context,
                      icon: Icons.group_work,
                      title: "My clubs",
                      onPressed: () {
                        Navigator.pushNamed(context, Navigation.MYCLUBS);
                      },
                    ),
                    const Divider(),
                    _buildProfileOption(
                      context,
                      icon: Icons.group,
                      title: "Join the clubs",
                      onPressed: () {
                        Navigator.pushNamed(context, Navigation.ALLCLUBS);
                      },
                    ),
                    const Divider(),
                    _buildProfileOption(
                      context,
                      icon: Icons.settings,
                      title: LU.of(context).settings,
                      onPressed: () {
                        Navigator.pushNamed(context, Navigation.SETTINGS);
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(SSC.p16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Palette.DARK_BLUE,
                backgroundColor: Palette.SOLITUDE,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SSC.p8),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: SSC.p10, horizontal: SSC.p22),
                elevation: 1,
              ),
              onPressed: () {
                showCustomDialog(
                  context: context,
                  title: LU.of(context).logout_title,
                  description: LU.of(context).logout_from_profile,
                  positiveText: LU.of(context).action_logout,
                  negativeText: LU.of(context).action_cancel,
                  onPositivePressed: () => signOut(context),
                );
              },
              child: Text(
                LU.of(context).action_logout,
                style: const TextStyle(
                  color: Palette.DARK_BLUE,
                  fontSize: SSC.p16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onPressed}) {
    return ListTile(
      leading: Icon(icon, color: Palette.MAIN),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: SSC.p16,
          fontWeight: FontWeight.w500,
          color: Palette.DARK_BLUE,
        ),
      ),
      onTap: onPressed,
      trailing: const Icon(Icons.arrow_right, color: Palette.DARK_BLUE),
    );
  }
}

void signOut(BuildContext context) async {
  await ooBloc.signOut();
  await PreferencesManager.instance.wipeOut();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const OrgOptimizeApp()),
    (route) => false,
  );
}
