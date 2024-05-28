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
// import 'package:urven/ui/widgets/profile_menu_option.dart';
// import 'package:urven/utils/lu.dart';

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Toolbar(isBackButtonVisible: false, title: LU.of(context).profile),
              ),
              ProfileMenuOption(
                title: "Join the clubs",
                onPressed: () {
                  Navigator.pushNamed(context, Navigation.ALLCLUBS);
                },
              ),
              ProfileMenuOption(
                title: "My clubs",
                onPressed: () {
                  Navigator.pushNamed(context, Navigation.MYCLUBS);
                },
              ),
              ProfileMenuOption(
                title: LU.of(context).personal_data,
                onPressed: () {
                  Navigator.pushNamed(context, Navigation.EDIT_USER_PROFILE);
                },
              ),
              ProfileMenuOption(
                title: LU.of(context).settings,
                onPressed: () {
                  Navigator.pushNamed(context, Navigation.SETTINGS);
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RawMaterialButton(
              disabledElevation: 1,
              child: Ink(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(SSC.p4),
                  ),
                  color: Palette.SOLITUDE,
                ),
                child: Container(
                  height: SSC.p40,
                  alignment: Alignment.center,
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
            ),
          ),
        ],
      ),
    );
  }
}

void signOut(BuildContext context) {
  ooBloc.signOut();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const OrgOptimizeApp()),
    (route) => false,
  );
}
