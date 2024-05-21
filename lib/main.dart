import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'auth/presentation/login_screen.dart';
import 'common/GlobalConfig.dart';
import 'constants/color_constant.dart';
import 'di/injection.dart';
import 'theme/theme_state_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency Injection
  await configureInjection();

  await POSDtls.initPOSDtls();
  await POSDefault.initPOSDefaults();

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((value) {
    runApp(ProviderScope(child: const MyApp()));
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = ref.watch(themeProvider);
    return ScreenUtilInit(
        designSize: const Size(926, 428),
        minTextAdapt: true,
        builder: (Widget? context) {
          return GetMaterialApp(
            title: 'Raptor POS',
            theme: isDark
                ? ThemeData(
                    brightness: Brightness.dark,
                    appBarTheme:
                        const AppBarTheme(backgroundColor: primaryDarkColor),
                    scaffoldBackgroundColor: backgroundDarkColor,
                    floatingActionButtonTheme:
                        const FloatingActionButtonThemeData(
                            backgroundColor: primaryLightColor),
                    primaryColor: primaryDarkColor,
                    backgroundColor: backgroundDarkColor)
                : ThemeData(
                    brightness: Brightness.light,
                    appBarTheme:
                        const AppBarTheme(backgroundColor: primaryLightColor),
                    scaffoldBackgroundColor: backgroundColor,
                    floatingActionButtonTheme:
                        const FloatingActionButtonThemeData(
                            backgroundColor: primaryLightColor),
                    primaryColor: primaryLightColor,
                    backgroundColor: backgroundColor),
            debugShowCheckedModeBanner: false,
            home: LoginScreen(),
          );
        });
  }
}
