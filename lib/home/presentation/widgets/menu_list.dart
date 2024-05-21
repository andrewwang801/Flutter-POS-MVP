import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:raptorpos/home/provider/menu_provider.dart';

import 'menu_card.dart';

class MenuList extends ConsumerStatefulWidget {
  MenuList({Key? key}) : super(key: key);

  @override
  _MenuListState createState() => _MenuListState();
}

class _MenuListState extends ConsumerState<MenuList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final menuHdr = ref.watch(menuHdrProvider);
    return menuHdr.when(data: ((data) {
      return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return MenuCard(menu: data[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: 10.w,
            );
          });
    }), error: (error, e) {
      return Center(
        child: Text(e.toString()),
      );
    }, loading: () {
      return Center(
        child: CircularProgressIndicator(),
      );
    });
  }
}
