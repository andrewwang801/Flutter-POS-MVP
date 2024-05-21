import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/dimension_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../model/theme_model.dart';

PreferredSize appBarWidget([bool backBtn = true]) {
  return PreferredSize(
    preferredSize: Size.fromHeight(AppBar().preferredSize.height),
    child: Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
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
            Image.asset(
              "assets/images/raptor-logo.png",
              fit: BoxFit.cover,
            ),
          ],
        ),
        leadingWidth: 250.w,
        title: Text('Ratpor POS', style: titleTextDarkStyle),
        actions: [
          IconButton(
              icon: Icon(themeNotifier.isDark
                  ? Icons.nightlight_round
                  : Icons.wb_sunny),
              onPressed: () {
                themeNotifier.isDark
                    ? themeNotifier.isDark = false
                    : themeNotifier.isDark = true;
              })
        ],
      );
    }),
  );
}
