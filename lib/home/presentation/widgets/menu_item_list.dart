import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/home/provider/menu/menu_provider.dart';

import '../../../common/widgets/responsive.dart';
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
          mainAxisExtent: Responsive.isMobile(context) ? 60.h : 55.h,
        ),
        itemBuilder: (BuildContext context, int index) {
          final item = data[index];
          return GestureDetector(
            onTap: () {},
            child: MenuItemCard(
              null,
              menuItem: item,
            ),
          );
        },
      );
    }, error: (error, e) {
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
