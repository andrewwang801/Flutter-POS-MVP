import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/home/model/menu_item_model.dart';
import 'package:raptorpos/home/provider/menu_provider.dart';

import 'menu_item_card.dart';

class MenuItemList extends ConsumerStatefulWidget {
  const MenuItemList({Key? key}) : super(key: key);

  @override
  _MenuItemListState createState() => _MenuItemListState();
}

class _MenuItemListState extends ConsumerState<MenuItemList> {
  @override
  Widget build(BuildContext context) {
    final menuID = ref.watch(menuIDProvider);
    final menuItems = ref.watch(menuByHdrProvider(menuID));
    return menuItems.when(data: (data) {
      return GridView.builder(
        itemCount: data.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisExtent: 50.h,
        ),
        itemBuilder: (BuildContext context, int index) {
          return MenuItemCard(
            menuItem: data[index],
          );
        },
      );
    }, error: (error, e) {
      return Center(
        child: Text(e.toString()),
      );
    }, loading: () {
      return CircularProgressIndicator();
    });
  }
}
