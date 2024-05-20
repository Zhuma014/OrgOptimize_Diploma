// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/ui/screens/authentication_screen.dart';

import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/wrapper.dart';

class OrgOptimizeApp extends StatelessWidget {
  const OrgOptimizeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
if (PreferencesManager.instance.isAuthenticated()) {
      return const MainWrapper();
    }
    return Scaffold(
      backgroundColor: Palette.BACKGROUND,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/image.png',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 80),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  child: Text(
                    LU.of(context).app_name,
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Palette.MAIN),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: Text(
                    LU.of(context).slogan,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 120),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthenticationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.MAIN,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    child: Text(
                      LU.of(context).get_started,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
