import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raptorpos/home/model/menu_item_model.dart';
import 'package:raptorpos/home/model/menu_model.dart';
import 'package:raptorpos/home/provider/menu/menu_provider.dart';

import 'menu_expandable_section.dart';

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
    final menuHdr = ref.watch(menuHdrProvider);
    final menuSearch = ref.watch(menuIDSearchProvider);

    return menuHdr.when(data: (menuData) {
      List<MenuModel> menus;
      if (menuID == 0) {
        menus = menuData.where((element) {
          return element.MenuID != 0;
        }).toList();
      } else {
        menus = menuData.where((element) {
          return element.MenuID == menuID;
        }).toList();
      }

      return menuItems.when(data: (data) {
        return ListView.builder(
            itemCount: menus.length,
            itemBuilder: (BuildContext context, index) {
              MenuModel menu = menus[index];
              List<MenuItemModel> menuItems = data.where((element) {
                bool searchFlag = true;
                if (menuSearch.isNotEmpty) {
                  searchFlag = element.itemName
                          ?.toLowerCase()
                          .contains(menuSearch.toLowerCase()) ??
                      false;
                }
                return element.menuID == menu.MenuID && searchFlag;
              }).toList();
              return MenuExpandableSection(menu: menu, menuItems: menuItems);
            });
      }, error: (error, e) {
        return Center(
          child: Text(e.toString()),
        );
      }, loading: () {
        return const Center(
          child: SizedBox(
              width: 30, height: 30, child: CircularProgressIndicator()),
        );
      });
    }, error: (Object error, StackTrace? e) {
      return Center(
        child: Text(e.toString()),
      );
    }, loading: () {
      return const Center(
          child: SizedBox(
              width: 30, height: 30, child: CircularProgressIndicator()));
    });
  }
}
