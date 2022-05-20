import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/menu_model.dart';

import 'menu_item_card.dart';

class MenuItemList extends StatefulWidget {
  const MenuItemList({Key? key}) : super(key: key);

  @override
  State<MenuItemList> createState() => _MenuItemListState();
}

class _MenuItemListState extends State<MenuItemList> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: menus[0].menuItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisExtent: 50.h,
      ),
      itemBuilder: (BuildContext context, int index) {
        return MenuItemCard(
          menuItem: menus[0].menuItems[index],
        );
      },
    );
  }
}
