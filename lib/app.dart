// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:urven/ui/widgets/sign_in_card.dart';
import 'package:urven/ui/widgets/sign_up_card.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/widgets/local_asset_image.dart';
import 'package:urven/utils/lu.dart';
import 'package:urven/utils/screen_size_configs.dart';

class UrvenApp extends StatelessWidget {
  const UrvenApp({super.key});

  @override
  Widget build(BuildContext context) {
    SSC().init(context); 
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Palette.BACKGROUND,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: SSC.p160),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LocalAssetImage(
                  name: 'image.png',
                  width: SSC.p63,
                  height: SSC.p85,
                  fit: BoxFit.fill,
                ),
                const SizedBox(width: SSC.p12),
                SizedBox(
                  height: SSC.p54,
                  width: SSC.p146,
                  child: Text(
                    LU.of(context).app_name,
                    style: const TextStyle(
                      fontSize: SSC.p50,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: SSC.p36),
            Center(
              child: Column(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: SSC.p235),
                    child: TabBar(
                      indicatorColor: Palette.YELLOWBUTTON,
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              LU.of(context).registration,
                              style: const TextStyle(
                                color: Colors.white,
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
                              LU.of(context).login,
                              style: const TextStyle(
                                color: Colors.white,
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
                  SignUpCard(),
                  SignInCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
