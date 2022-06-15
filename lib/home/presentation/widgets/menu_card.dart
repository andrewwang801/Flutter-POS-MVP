import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/extension/color_extension.dart';
import 'package:raptorpos/home/model/menu_model.dart';
import 'package:raptorpos/home/provider/menu/menu_provider.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../../constants/color_constant.dart';
import '../../../constants/text_style_constant.dart';

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

class MenuCard extends ConsumerStatefulWidget {
  final MenuModel menu;
  const MenuCard({required this.menu, Key? key}) : super(key: key);
  @override
  _MenuCardState createState() => _MenuCardState();
}

class _MenuCardState extends ConsumerState<MenuCard> {
  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      color: HexColor(widget.menu.RGBColour ?? 'ffffff').withOpacity(0.4),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          ref.read(menuIDProvider.notifier).state = widget.menu.MenuID;
        },
        child: Container(
          width: 120.w,
          padding: EdgeInsets.all(4.0),
          // decoration: BoxDecoration(
          //   color: Colors.transparent,
          //   borderRadius: BorderRadius.circular(6.0),
          //   boxShadow: [
          //     BoxShadow(
          //       color: isDark ? primaryDarkColor : Colors.white,
          //       spreadRadius: 0.0,
          //     ),
          //   ],
          // ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.menu.MenuName ?? '',
                  textAlign: TextAlign.center,
                  style: isDark ? bodyTextDarkStyle : bodyTextLightStyle),
            ],
          ),
        ),
      ),
    );
  }
}
