import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/widgets/alert_dialog.dart';
// ignore: unused_import
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/functions/application/function_provider.dart';
import 'package:raptorpos/functions/application/function_state.dart';

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

  final data = MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
  if (data.size.shortestSide < 600) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((value) {
      runApp(ProviderScope(child: const MyApp()));
    });
  } else {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((value) {
      runApp(ProviderScope(child: const MyApp()));
    });
  }
  // SystemChrome.setPreferredOrientations(
  //         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
  //     .then((value) {
  //   runApp(ProviderScope(child: const MyApp()));
  // });
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = ref.watch(themeProvider);
    return OrientationBuilder(builder: (_, orientation) {
      return ScreenUtilInit(
          designSize: orientation == Orientation.landscape
              ? Size(926, 428)
              : Size(428, 926),
          // designSize: Size(428, 926),
          minTextAdapt: true,
          builder: (BuildContext context, Widget? child) {
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
                          const AppBarTheme(backgroundColor: Colors.white),
                      scaffoldBackgroundColor: Colors.white,
                      floatingActionButtonTheme:
                          const FloatingActionButtonThemeData(
                              backgroundColor: primaryLightColor),
                      primaryColor: Colors.white,
                      backgroundColor: Colors.white),
              debugShowCheckedModeBanner: false,
              home: LoginScreen(),
            );
          });
    });
  }
}
