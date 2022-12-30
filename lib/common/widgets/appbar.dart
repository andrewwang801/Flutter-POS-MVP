import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/widgets/responsive.dart';

import '../../constants/dimension_constant.dart';
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
                color: isDark ? Colors.white : Colors.black,
                size: Responsive.isTablet(context) ? lgiconSize : mdiconsize,
              ),
            )
          else
            IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
        ],
      ),
      actions: [
        // IconButton(
        //     icon: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
        //     onPressed: () {
        //       isDark ? isDark = false : isDark = true;
        //       ref.read(themeProvider.notifier).setTheme(isDark);
        //     })
      ],
    );
  }
}
