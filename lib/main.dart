// ignore_for_file: depend_on_referenced_packages, unnecessary_nullable_for_final_variable_declarations, prefer_const_constructors

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urven/app.dart';
import 'package:urven/data/network/general_http_overrider.dart';
import 'package:urven/data/network/push/notification.dart';
import 'package:urven/data/preferences/preferences_manager.dart';
import 'package:urven/firebase_options.dart';
import 'package:urven/internal/bloc/cubits/bottom_nav_bar_bloc.dart';
import 'package:urven/l10n/provider.dart';
import 'package:urven/ui/screens/navigation.dart';
import 'package:urven/ui/theme/font.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/ui/theme/text.dart';
import 'package:urven/utils/lu.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:provider/provider.dart';
import 'package:urven/utils/screen_size_configs.dart';
import 'package:flutter/services.dart';
import 'package:urven/wrapper.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterTimezone.getLocalTimezone();
  if (timeZoneName == null) {
    tz.setLocalLocation(tz.getLocation('Asia/Almaty'));
  } else {
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await PreferencesManager.instance.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.setup();

  final BottomNavBarCubit bottomNavBarCubit = BottomNavBarCubit();

  _configureLocalTimeZone();

  LocaleProvider localeProvider = LocaleProvider();
  await localeProvider.initialize();




  // FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  // await NotificationService.instance.setup();
  // await NotificationService.instance.requestPermissions();

  // Map<String, dynamic>? notificationData;

  // NotificationAppLaunchDetails? appLaunchDetails =
  //     await NotificationService.instance.getAppLaunchDetails();
  // if (appLaunchDetails != null) {
  //   Logger.d('main()',
  //       'appLaunchDetails.didNotificationLaunchApp: ${appLaunchDetails.didNotificationLaunchApp}');
  //   String? payload = appLaunchDetails.notificationResponse?.payload;
  //   if (payload != null) {
  //     initialRoute = Navigation.ORDER_FEEDBACK;
  //     notificationData = jsonDecode(payload);
  //     Logger.d('main()', 'notificationData: $notificationData');
  //   }
  // }

  HttpOverrides.global = GeneralHttpOverrider();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<BottomNavBarCubit>.value(value: bottomNavBarCubit),
    ],
    child: ChangeNotifierProvider<LocaleProvider>.value(
        value: localeProvider,
        child: Consumer<LocaleProvider>(builder: (context, provider, _) {
          return MaterialApp(
            // Flags
            // debugShowCheckedModeBanner: kReleaseMode ? false : true,
            debugShowCheckedModeBanner: false,

            // Theme
            themeMode: ThemeMode.light,
            // There is no dark mode support yet
            theme: ThemeData(
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),

              // Brightness & Colors
              brightness: Brightness.light,
              // colorScheme: const ColorScheme.light(
              //   primary: Colors.white,
              //   secondary: Palette.OUTRAGEOUS_ORANGE,
              // ),
              primaryColor: Colors.white,
              scaffoldBackgroundColor: Palette.BACKGROUND,
              // splashColor: Palette.OUTRAGEOUS_ORANGE,

              unselectedWidgetColor: Palette.NOT_OUTRAGEOUS,

              // Font
              fontFamily: Font.NUNITO,

              dialogTheme: const DialogTheme(
                backgroundColor: Colors.white,
                elevation: SSC.p2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(SSC.p8),
                  ),
                ),
                titleTextStyle: TextStyle(
                  color: Palette.DARK_BLUE,
                  fontSize: SSC.p20,
                  fontWeight: FontWeight.w800,
                ),
                contentTextStyle: TextStyle(
                  color: Palette.DARK_BLUE,
                  fontSize: SSC.p14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                  wordSpacing: 0.25,
                  height: 1.5,
                ),
              ),

              // buttonBarTheme: const ButtonBarThemeData(
              //   buttonTextTheme: ButtonTextTheme.primary,
              // ),

              // buttonTheme: const ButtonThemeData(
              //   buttonColor: Palette.OUTRAGEOUS_ORANGE,
              // ),

              // Text
              textTheme: textTheme,
            ),

            // Localization

            localizationsDelegates: LU.localizationsDelegates,
            supportedLocales: LU.supportedLocales,
            locale: provider.locale,

            // Routes
            initialRoute: PreferencesManager.instance.isAuthenticated()
                ? Navigation.HOME
                : Navigation.INDEX,
            onGenerateInitialRoutes: (String initialRoute) {
              return [
                MaterialPageRoute(
                    builder: (context) =>
                        PreferencesManager.instance.isAuthenticated()
                            ? MainWrapper()
                            : OrgOptimizeApp()),
              ];
            },
            // by default open Intro screen
            routes: Navigation.getRoutes(),

            navigatorKey: navigatorKey,
          );
        })),
  ));
}
