import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'constants/color_constant.dart';
import 'model/theme_model.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(builder:
          (BuildContext context, ThemeModel themeNotifier, Widget? child) {
        return ScreenUtilInit(
            designSize: const Size(926, 428),
            builder: (Widget? context) {
              return GetMaterialApp(
                title: 'Raptor POS',
                theme: themeNotifier.isDark
                    ? ThemeData(
                        brightness: Brightness.dark,
                        appBarTheme: const AppBarTheme(
                            backgroundColor: primaryDarkColor),
                        scaffoldBackgroundColor: backgroundDarkColor,
                        floatingActionButtonTheme:
                            const FloatingActionButtonThemeData(
                                backgroundColor: primaryLightColor),
                        primaryColor: primaryDarkColor,
                        backgroundColor: backgroundDarkColor)
                    : ThemeData(
                        brightness: Brightness.light,
                        appBarTheme: const AppBarTheme(
                            backgroundColor: primaryLightColor),
                        scaffoldBackgroundColor: backgroundColor,
                        floatingActionButtonTheme:
                            const FloatingActionButtonThemeData(
                                backgroundColor: primaryLightColor),
                        primaryColor: primaryLightColor,
                        backgroundColor: backgroundColor),
                debugShowCheckedModeBanner: false,
                home: HomeScreen(),
              );
            });
      }),
    );
  }
}
