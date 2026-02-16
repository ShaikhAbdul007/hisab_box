import 'dart:io';
import 'package:http/io_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'common_widget/colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConfig.init();
  await ScreenUtil.ensureScreenSize();
  await GetStorage.init();

  checkResponse();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

Future<void> checkResponse() async {
  // final client = createCustomClient();

  // final url = Uri.parse(
  //   'https://daslsfwsomiicnrbfniw.supabase.co/rest/v1/sales?select=id&limit=1',
  // );

  // final res = await client.get(
  //   url,
  //   headers: {
  //     'apikey': 'sb_publishable_1Y93bgokI5bcfLuYtjsn0g_FVW7NjaF',
  //     'Authorization': 'Bearer sb_publishable_1Y93bgokI5bcfLuYtjsn0g_FVW7NjaF',
  //   },
  // );

  final user = Supabase.instance.client.auth.currentUser;
  print('USER -> $user');
  final session = Supabase.instance.client.auth.currentSession;
  print('SESSION -> $session');
}

IOClient createCustomClient() {
  final HttpClient httpClient = HttpClient();

  // Critical tweaks for unstable networks / IPv6 paths
  httpClient.connectionTimeout = const Duration(seconds: 10);
  httpClient.idleTimeout = const Duration(seconds: 10);
  httpClient.maxConnectionsPerHost = 5;

  // Helps avoid some HTTP/2 negotiation edge cases
  httpClient.autoUncompress = true;

  return IOClient(httpClient);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.initialRoute,
          getPages: AppRoutes.getPage,
          title: 'HisaabBox',
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: widget!,
            );
          },
          theme: ThemeData(
            hoverColor: AppColors.transparent,
            highlightColor: AppColors.transparent,
            splashColor: AppColors.transparent,
            splashFactory: NoSplash.splashFactory,
            bottomAppBarTheme: BottomAppBarThemeData(
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
