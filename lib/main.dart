import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'common_widget/colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await ScreenUtil.ensureScreenSize();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GetStorage.init();
  runApp(const MyApp());
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
