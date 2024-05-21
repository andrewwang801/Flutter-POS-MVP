import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:raptorpos/model/menu_model.dart';

import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../model/theme_model.dart';

const List<MaterialColor> menuColors = [
  Colors.green,
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.pink,
  Colors.blue,
  Colors.grey,
  Colors.teal,
];

class MenuCard extends StatelessWidget {
  final MenuModel menu;
  const MenuCard({required this.menu, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Container(
        width: 120.w,
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: menuColors[menu.color],
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: [
            BoxShadow(
              color: themeNotifier.isDark ? primaryDarkColor : Colors.white,
              spreadRadius: 2.0,
              blurRadius: 2.0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(menu.label ?? '',
                textAlign: TextAlign.center, style: bodyTextLightStyle),
          ],
        ),
      );
    });
  }
}
