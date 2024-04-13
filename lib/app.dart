// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/ui/screens/sign_in.dart';
import 'package:urven/ui/screens/sign_up.dart';

import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/lu.dart';

class OrgOptimizeApp extends StatelessWidget {
  const OrgOptimizeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/image.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 80),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  child: Text(
                    LU.of(context).app_name,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Palette.MAIN),
                  ),
                ),
                Container(
                  height: 50,
                  child: Text(
                    LU.of(context).slogan,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey),
                  ),
                ),
                SizedBox(height: 80),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
                    child: Text(                    LU.of(context).login,
),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.MAIN,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                    LU.of(context).registration,
                      style: TextStyle(color: Palette.MAIN),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: Palette.MAIN),
                      ),
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
