import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../model/menu_item_model.dart';
import '../../model/theme_model.dart';

List<MaterialColor> menuItemColors = <MaterialColor>[
  Colors.grey,
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.pink,
  Colors.blue,
  Colors.grey,
  Colors.teal,
];

class MenuItemCard extends StatefulWidget {
  final MenuItemModel menuItem;
  MenuItemCard({required this.menuItem, Key? key}) : super(key: key);

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            color: menuItemColors[widget.menuItem.color],
            border: Border.all(
              color: themeNotifier.isDark ? backgroundDarkColor : Colors.white,
            ),
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color:
                    themeNotifier.isDark ? backgroundDarkColor : Colors.white,
                spreadRadius: 1.0,
                blurRadius: 2.0,
              ),
            ]),
        child: Center(
          child: Text(widget.menuItem.label ?? '',
              textAlign: TextAlign.center,
              style: themeNotifier.isDark
                  ? bodyTextDarkStyle
                  : bodyTextLightStyle.copyWith(color: Colors.black)),
        ),
      );
    });
  }
}
