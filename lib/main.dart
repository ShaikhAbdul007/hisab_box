import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inventory/helper/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/module/push_notification/local_notification_service.dart';
import 'package:inventory/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'common_widget/colors.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background body message: ${message.notification?.body}");
  print("Handling a background title message: ${message.notification?.title}");
  print("Handling a background topic message: ${message.data['topic']}");
  print(
    "Handling a background id coming from data message: ${message.data['id']}",
  );
  String payload = message.data['topic'];
  String id;
  if (payload == 'tracker') {
    id = message.data['id'];
    await NotificationServices.handlePayload(payload, id);
  } else {
    id = '0';
    await NotificationServices.handlePayload(payload, id);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await ScreenUtil.ensureScreenSize();
  // await LocalService.initHive();
  await GetStorage.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  checkResponse();
  runApp(const MyApp());
}

Future<void> checkResponse() async {
  // final user = Supabase.instance.client.auth.currentUser;
  // AppLogger.info(('USER -> $user').toString());
  // final session = Supabase.instance.client.auth.currentSession;
  // AppLogger.info(('SESSION -> $session').toString());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  initState() {
    super.initState();
    if (!kIsWeb) {
      NotificationServices.notificationPermission();
      NotificationServices.forgroundIosMessege();
      NotificationServices.getDeviceToken();
      NotificationServices.init(context);
      checkInitialMessage();
    }
  }

  void checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      String payload = initialMessage.data['topic'];
      String id;
      if (payload == 'tracker') {
        id = initialMessage.data['id'];
        //  handlePayload(payload, id);
      } else {
        id = '0';
        // handlePayload(payload, id);
      }
    }
  }

  void handlePayload(String? payload, String id) async {
    print('Payload: $payload, ID: $id');
    Future.delayed(const Duration(seconds: 4), () {
      if (payload == null || payload.isEmpty) {
        print('Payload is null');
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
    });
  }

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit ko properly configure kiya gaya hai orientation handle karne ke liye

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Aapke design ka base size
      splitScreenMode: true,
      minTextAdapt: true,
      // useInheritedMediaQuery zaroori hai orientation changes ke liye
      useInheritedMediaQuery: true,

      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.initialRoute,
          getPages: AppRoutes.getPage,
          title: 'HisabBox',

          // Builder mein textScaler ko 1.0 par fix rakha hai
          // Taaki phone ki system setting se aapka UI na phate
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: widget!,
            );
          },

          theme: ThemeData(
            hoverColor: AppColors.transparent,
            highlightColor: AppColors.transparent,
            splashColor: AppColors.transparent,
            splashFactory: NoSplash.splashFactory,

            // TextTheme ko yahan globally configure kar sakte hain .sp ke saath
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),

            bottomAppBarTheme: const BottomAppBarThemeData(
              color: AppColors.whiteColor,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: AppColors.greyColorShade100,
            ),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          ),
        );
      },
    );
  }
}




//class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: Size(375, 812),
//       splitScreenMode: true,
//       minTextAdapt: true,

//       builder: (context, child) {
//         return GetMaterialApp(
//           debugShowCheckedModeBanner: false,
//           initialRoute: AppRoutes.initialRoute,
//           getPages: AppRoutes.getPage,
//           title: 'HisaabBox',
//           builder: (context, widget) {
//             return MediaQuery(
//               data: MediaQuery.of(
//                 context,
//               ).copyWith(textScaler: TextScaler.linear(1.0)),
//               child: widget!,
//             );
//           },
//           theme: ThemeData(
//             hoverColor: AppColors.transparent,
//             highlightColor: AppColors.transparent,
//             splashColor: AppColors.transparent,
//             splashFactory: NoSplash.splashFactory,
//             bottomAppBarTheme: BottomAppBarThemeData(
//               color: AppColors.whiteColor,
//             ),
//             bottomNavigationBarTheme: BottomNavigationBarThemeData(
//               backgroundColor: AppColors.greyColorShade100,
//             ),
//             colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
//           ),
//         );
//       },
//     );
//   }
// }