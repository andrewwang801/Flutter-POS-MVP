import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../common/GlobalConfig.dart';
import '../../common/widgets/alert_dialog.dart';
import '../../common/widgets/appbar.dart';
import '../../common/widgets/custom_button.dart';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                message: next.errMsg,
                onConfirm: () {},
              );
            });
      }
    });

    isDark = ref.watch(themeProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBarWidget(false),
      ),
      body: SafeArea(
        child: Center(
          child: Row(
            children: [
              Expanded(child: leftLogo()),
              Expanded(child: rightLoginForm()),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: Responsive.isMobile(context) ? 220.h : 160.h,
          height: Responsive.isMobile(context) ? 40.h : 25.h,
          decoration: BoxDecoration(
            color: isDark
                ? primaryDarkColor.withOpacity(0.8)
                : primaryLightColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Center(
            child: Text(
              pin,
              style: titleTextDarkStyle,
            ),
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Container(
          width: Responsive.isMobile(context) ? 220.h : 160.h,
          color: Colors.transparent,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: NumPad(
                delete: () {},
                onSubmit: () {},
                buttonColor:
                    isDark ? primaryButtonDarkColor : primaryButtonColor,
                controller: _controller),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        ElevatedButton(
          onPressed: () {
            pinSignIn();
          },
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.all(
              Size(
                Responsive.isMobile(context) ? 220.h : 160.h,
                Responsive.isMobile(context) ? 40.h : 25.h,
              ),
            ),
            backgroundColor: MaterialStateProperty.all(
                isDark ? primaryDarkColor : primaryLightColor),
          ),
          child: Text(
            'Sign In',
            style: isDark
                ? buttonTextDarkStyle
                : buttonTextLightStyle.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> pinSignIn() async {
    if (pin.isEmpty) {
      return;
    }
    await ref.read(authProvider.notifier).pinSingIn(pin);
  }
}
