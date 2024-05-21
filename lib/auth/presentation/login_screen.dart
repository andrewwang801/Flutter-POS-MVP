import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      body: SafeArea(
        child: Center(
          child: Responsive.isMobile(context)
              ? Column(
                  children: [
                    Expanded(flex: 1, child: leftLogo()),
                    Expanded(flex: 3, child: rightLoginForm()),
                  ],
                )
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: Spacing.xs, vertical: Spacing.sm),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Spacing.xs, vertical: Spacing.sm),
              decoration: BoxDecoration(
                color: isDark
                    ? primaryDarkColor.withOpacity(0.8)
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
          Container(
            color: Colors.transparent,
            child: NumPad(
                delete: () {},
                onSubmit: () {},
                backgroundColor: Colors.transparent,
                buttonColor:
                    isDark ? primaryButtonDarkColor : backgroundColorVariant,
                isDark: isDark,
                controller: _controller),
          ),
          Container(
            padding: EdgeInsets.all(Spacing.xs),
            child: ElevatedButton(
              onPressed: () {
                pinSignIn();
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(40),
                  primary: isDark ? primaryDarkColor : backgroundColorVariant,
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
