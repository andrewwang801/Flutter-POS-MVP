import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/extension/workable.dart';
import 'package:raptorpos/functions/application/function_provider.dart';
import 'package:raptorpos/functions/application/function_state.dart';
import 'package:raptorpos/functions/model/function_model.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../common/GlobalConfig.dart';
import '../../common/widgets/alert_dialog.dart';
import '../../common/widgets/numpad.dart';
import '../../common/widgets/responsive.dart';
import '../../constants/color_constant.dart';
import '../../constants/dimension_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../floor_plan/presentation/floor_plan_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../provider/auth_provider.dart';
import '../provider/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String pin = '';
  final TextEditingController _controller = TextEditingController();

  late bool isDark;

  @override
  void initState() {
    _controller.addListener(() {
      setState(() {
        pin = _controller.text;
      });
    });

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      ref.read(functionProvider.notifier).fetchFunctions();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FunctionState state = ref.watch(functionProvider);
    if (state.workable == Workable.ready) {
      GlobalConfig.functions = state.data?.functionList ?? <FunctionModel>[];
    }

    ref.listen(authProvider, (Object? previous, Object? next) {
      if (next is AuthSuccessState) {
        if (POSDtls.TBLManagement) {
          Get.offAll(const FloorPlanScreen());
        } else {
          Get.offAll(HomeScreen());
        }
      } else if (next is AuthErrorState) {
        showDialog(
            context: context,
            builder: (context) {
              return AppAlertDialog(
                title: 'Error',
                isDark: isDark,
                message: next.errMsg,
                onConfirm: () {},
              );
            });
      }
    });

    isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? primaryDarkColor : backgroundColor,
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
              icon: Icon(
                (ScreenUtil().orientation == Orientation.portrait)
                    ? Icons.screen_lock_landscape
                    : Icons.screen_lock_portrait,
              ),
              color: isDark ? backgroundColor : primaryDarkColor,
              onPressed: () async {
                if (ScreenUtil().orientation == Orientation.portrait) {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight
                  ]).then((value) {
                    ScreenUtil().setWidth(926);
                    ScreenUtil().setHeight(428);
                  });
                } else {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitDown,
                    DeviceOrientation.portraitUp
                  ]).then((value) {
                    ScreenUtil().setWidth(428);
                    ScreenUtil().setHeight(926);
                  });
                }
                // const platform =
                //     MethodChannel('samples.flutter.dev/orientation');
                // try {
                //   await platform.invokeMethod('setOrientation');
                // } catch (e) {
                //   print(e.toString());
                // }
              }),
          IconButton(
              icon: Icon(
                isDark ? Icons.wb_sunny : Icons.nightlight_round,
              ),
              color: isDark ? backgroundColor : primaryDarkColor,
              onPressed: () {
                isDark ? isDark = false : isDark = true;
                ref.read(themeProvider.notifier).setTheme(isDark);
              }),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(Spacing.xs),
          child: Responsive.isMobile(context)
              ? OrientationBuilder(builder: (context, orientation) {
                  if (orientation == Orientation.portrait) {
                    return Column(
                      children: [
                        Expanded(flex: 1, child: leftLogo()),
                        Expanded(flex: 1, child: rightLoginForm()),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(flex: 3, child: leftLogo()),
                        Expanded(flex: 2, child: rightLoginForm()),
                      ],
                    );
                  }
                })
              : Row(
                  children: [
                    Spacer(),
                    Expanded(flex: 4, child: leftLogo()),
                    Expanded(flex: 3, child: rightLoginForm()),
                    Spacer(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget leftLogo() {
    return Center(
      child: Image.asset(
        'assets/images/raptor-logo.png',
        fit: BoxFit.contain,
        color: isDark ? backgroundColor : backgroundDarkColor,
      ),
    );
  }

  Widget rightLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(Spacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding:
                EdgeInsets.symmetric(vertical: Spacing.xs, horizontal: 6.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Spacing.xs, vertical: Spacing.sm),
              decoration: BoxDecoration(
                color: isDark
                    ? backgroundDarkColor.withOpacity(0.8)
                    : backgroundColorVariant.withOpacity(0.8),
                borderRadius: BorderRadius.circular(Spacing.sm),
              ),
              child: Center(
                child: Text(
                  pin,
                  style: isDark ? titleTextDarkStyle : titleTextLightStyle,
                  maxLines: 1,
                ),
              ),
            ),
          ),
          Responsive.isMobile(context)
              ? Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: NumPad(
                        delete: () {},
                        onSubmit: () {},
                        backgroundColor: Colors.transparent,
                        buttonColor: isDark
                            ? backgroundDarkColor
                            : backgroundColorVariant,
                        isDark: isDark,
                        controller: _controller),
                  ),
                )
              : Container(
                  height: 0.25.sh,
                  color: Colors.transparent,
                  child: NumPad(
                      delete: () {},
                      onSubmit: () {},
                      backgroundColor: Colors.transparent,
                      buttonColor:
                          isDark ? backgroundDarkColor : backgroundColorVariant,
                      isDark: isDark,
                      controller: _controller),
                ),
          Container(
            padding:
                EdgeInsets.symmetric(vertical: Spacing.xs, horizontal: 6.0),
            child: ElevatedButton(
              onPressed: () {
                pinSignIn();
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(40),
                  primary:
                      isDark ? backgroundDarkColor : backgroundColorVariant,
                  padding: EdgeInsets.all(Spacing.xs),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Spacing.sm))),
              child: Text(
                'Sign In',
                style: isDark ? buttonTextDarkStyle : buttonTextLightStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pinSignIn() async {
    if (pin.isEmpty) {
      return;
    }
    await ref.read(authProvider.notifier).pinSingIn(pin);
  }
}
