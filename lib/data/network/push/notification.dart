// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:urven/data/preferences/preferences_manager.dart';

import 'package:urven/firebase_options.dart';
import 'package:urven/utils/logger.dart';

const String TAG = 'NotificationService';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  Logger.d(TAG, 'onBackgroundMessage() -> message: ${message.messageId}');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.setup();
  NotificationService.instance.show(message);
}

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  String? payload = response.payload;
  Logger.d(TAG, 'onDidReceiveBackgroundNotificationResponse() -> payload: $payload');
}

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late final AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('logo');

  late final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {},
  );

  late final AndroidNotificationChannel channel =
      const AndroidNotificationChannel(
    'org_optimize',
    'OrgOptimize',
    importance: Importance.high,
    enableLights: true,
    enableVibration: true,
    showBadge: true,
    playSound: true,
  );

  bool isFlutterLocalNotificationsInitialized = false;

  Future<void> setup() async {
    Logger.d(TAG, 'setup()');

    if (isFlutterLocalNotificationsInitialized) return;

    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      ),
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await requestNotificationPermissions();

    FirebaseMessaging.onMessage.listen(showForegroundMessage);

    isFlutterLocalNotificationsInitialized = true;

    await _getAndSaveFirebaseMessagingToken();
  }

  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger.d(TAG, 'User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      Logger.d(TAG, 'User granted provisional permission');
    } else {
      Logger.d(TAG, 'User declined or has not accepted permission');
    }
  }

  Future<void> _getAndSaveFirebaseMessagingToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await PreferencesManager.instance.saveFirebaseMessagingToken(token);
      Logger.d(TAG, 'Firebase Messaging Token: $token');
    } else {
      Logger.d(TAG, 'Failed to get Firebase Messaging Token.');
    }
  }

  void show(RemoteMessage message) {
    Logger.d(TAG, 'show() -> message: ${message.toMap()}');

    Map<String, dynamic> data = message.data;
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.max,
            enableLights: true,
            enableVibration: true,
            playSound: true,
          ),
        ),
        payload: jsonEncode(data),
      );
    }
  }

  void showForegroundMessage(RemoteMessage message) {
    Logger.d(TAG, 'showForegroundMessage() -> message: ${message.toMap()}');

    Map<String, dynamic> data = message.data;
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.max,
            enableLights: true,
            enableVibration: true,
            playSound: true,
          ),
        ),
        payload: jsonEncode(data),
      );
    }
  }

  Future<void> cancelAll() async {
    Logger.d(TAG, 'cancelAll()');
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    Logger.d(TAG, 'onDidReceiveNotificationResponse() -> response.payload: ${response.payload}');

    String? payload = response.payload;

    if (payload == null) return;

    Logger.d(TAG, 'onDidReceiveNotificationResponse() -> payload: $payload');

    switch (response.notificationResponseType) {
      case NotificationResponseType.selectedNotification:
        break;
      case NotificationResponseType.selectedNotificationAction:
        break;
    }
  }
}


