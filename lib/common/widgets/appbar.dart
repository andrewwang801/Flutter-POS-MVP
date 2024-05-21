import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/dimension_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../theme/theme_state_notifier.dart';

class AppBarWidget extends ConsumerWidget {
  final bool backBtn;

  AppBarWidget(this.backBtn);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = ref.watch(themeProvider);
    return AppBar(
      leading: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (backBtn)
            IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.white,
                  size: iconSize,
                )),
        ],
      ),
      // leadingWidth: 200.w,
      title: Image.asset(
        "assets/images/raptor-logo.png",
        fit: BoxFit.contain,
        height: appBarHeight,
      ),
      actions: [
        IconButton(
            icon: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
            onPressed: () {
              isDark ? isDark = false : isDark = true;
              ref.read(themeProvider.notifier).setTheme(isDark);
            })
      ],
    );
  }
}
