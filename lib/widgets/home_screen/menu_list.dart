import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/menu_model.dart';

import 'menu_card.dart';

class MenuList extends StatefulWidget {
  MenuList({Key? key}) : super(key: key);

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (BuildContext context, int index) {
          return MenuCard(menu: menus[index]);
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            width: 10.w,
          );
        });
  }
}
