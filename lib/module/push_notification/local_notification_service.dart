import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inventory/helper/logger.dart';

class NotificationServices {
  NotificationServices._();
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void notificationPermission() async {
    NotificationSettings setting = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    if (setting.authorizationStatus == AuthorizationStatus.authorized) {
      //saveNotificationPermissionValue(true);
      AppLogger.info('Notifcation permission granted');
    } else if (setting.authorizationStatus == AuthorizationStatus.provisional) {
      //saveNotificationPermissionValue(true);
      AppLogger.info('Notifcation permission granted');
    } else {
      AppSettings.openAppSettings(type: AppSettingsType.notification);
      AppLogger.info('Notifcation permission not granted');
    }
  }

  static Future<String> getDeviceToken() async {
    String? getDeviceToken = await messaging.getToken();
    AppLogger.info('getDeviceToken is $getDeviceToken');
    return getDeviceToken ?? 'No Device Token Found';
  }

  static Future<void> initLocalNotification(
    BuildContext context,
    RemoteMessage message,
  ) async {
    var androidInitializationSettings = AndroidInitializationSettings(
      '@drawable/ic_launcher',
    );
    var iosInitializationSettings = DarwinInitializationSettings();

    var initialization = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    try {
      await flutterLocalNotificationsPlugin.initialize(
        initialization,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          AppLogger.info(
            "onDidReceiveNotificationResponse: ${response.payload}",
          );
          AppLogger.info("onDidReceiveNotificationResponse: ${response.id}");
          String id = response.id.toString(); // Convert id to String

          handlePayload(response.payload, id);
        },
        onDidReceiveBackgroundNotificationResponse: (
          NotificationResponse response,
        ) {
          AppLogger.info(
            "onDidReceiveBackgroundNotificationResponse: ${response.payload}",
          );
          AppLogger.info(
            "onDidReceiveBackgroundNotificationResponse: ${response.id}",
          );
          String id = response.id.toString(); // Convert id to String

          handlePayload(response.payload, id);
        },
      );
    } catch (e) {
      AppLogger.info('Error during initialization: $e');
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.max,
          playSound: true,
        );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidNotificationChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          // actions: <AndroidNotificationAction>[
          //   AndroidNotificationAction(
          //     '0', // Another action key
          //     'Yes',
          //     showsUserInterface: true,
          //     titleColor: AppColors.greenColor,
          //   ),
          //   AndroidNotificationAction(
          //       '1', // Another action key
          //       'SOS',
          //       showsUserInterface: true,
          //       titleColor: AppColors.redColor,
          //       inputs: []),
          // ],
          icon: '@drawable/ic_launcher',
        );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    int notificationId = 0;

    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
        notificationId,
        message.notification?.title.toString(),
        message.notification?.body.toString(),
        notificationDetails,
        payload: message.data['topic'],
      );
    });
  }

  static Future forgroundIosMessege() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> init(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((message) async {
      AppLogger.info(
        "Handling a onMessage body message: ${message.notification?.body}",
      );
      AppLogger.info(
        "Handling a onMessage title message: ${message.notification?.title}",
      );
      AppLogger.info(
        "Handling a onMessage topic message: ${message.data['topic']}",
      );
      AppLogger.info("Handling a onMessage id message: ${message.data['id']}");
      await initLocalNotification(context, message);
      await showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      AppLogger.info(
        "Handling a onMessageOpenedApp body message: ${message.notification?.body}",
      );
      AppLogger.info(
        "Handling a onMessageOpenedApp title message: ${message.notification?.title}",
      );
      AppLogger.info(
        "Handling a onMessageOpenedApp topic message: ${message.data['topic']}",
      );
      AppLogger.info(
        "Handling a onMessageOpenedApp id message: ${message.data['id']}",
      );
      String payload = message.data['topic'];
      String id;
      if (payload == 'tracker') {
        id = message.data['id'];

        await handlePayload(payload, id);
      } else {
        id = '0';
        await handlePayload(payload, id);
      }
    });
  }

  static Future<void> handlePayload(String? payload, String id) async {
    AppLogger.info('Payload: $payload, ID: $id');
    if (payload == null || payload.isEmpty) {
      AppLogger.info('Payload is null');
      // MyRoutes.navigateToRoute(routeName: MyRoutes.dashBoardView);
    } else if (payload == 'tracker') {
      // MyRoutes.navigateToRoute(
      //   routeName: MyRoutes.safetyUpdate,
      //   data: {'navigateFrom': 'notification', 'id': id},
      // );
    } else if (payload == 'circular') {
      // MyRoutes.navigateToRoute(
      //   routeName: MyRoutes.circularView,
      //   data: {"navigateFrom": 'notification'},
      // );
    } else {
      // MyRoutes.navigateToRoute(routeName: MyRoutes.dashBoardView);
    }
  }
}
