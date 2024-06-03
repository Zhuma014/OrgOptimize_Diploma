// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/sign_in_card.dart';
import 'package:urven/ui/widgets/sign_up_card.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SSC().init(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: SSC.p160),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  LU.of(context).app_name,
                  style: const TextStyle(
                    fontSize: SSC.p30,
                    fontWeight: FontWeight.w700,
                    color: Palette.MAIN,
                  ),
                ),
                const SizedBox(
                  height: SSC.p20,
                ),
                Text(
                  LU.of(context).login_or_create_account,
                  style: const TextStyle(
                    fontSize: SSC.p17,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
            const SizedBox(height: SSC.p36),
            Center(
              child: Column(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: SSC.p240),
                    child: TabBar(
                      indicatorColor: Palette.MAIN,
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              LU.of(context).login,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: SSC.p14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              LU.of(context).registration,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: SSC.p14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SSC.p31),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  SignInCard(),
                  SignUpCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
