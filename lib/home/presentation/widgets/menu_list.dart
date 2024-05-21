import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raptorpos/constants/color_constant.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/constants/text_style_constant.dart';
import 'package:raptorpos/home/model/menu_model.dart';

import 'package:raptorpos/home/provider/menu/menu_provider.dart';

class MenuList extends ConsumerStatefulWidget {
  MenuList({Key? key}) : super(key: key);

  @override
  _MenuListState createState() => _MenuListState();
}

class _MenuListState extends ConsumerState<MenuList> {
  int selectedMenuIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String searchKeyword = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final menuHdr = ref.watch(menuHdrProvider);
    return menuHdr.when(data: (data) {
      List<MenuModel> menus = [];
      menus.addAll(data);
      menus.insert(0, MenuModel(0, 'All', 'All'));

      return Row(
        children: [
          _menuDropDown(menus),
          horizontalSpaceSmall,
          Expanded(child: _searchBar()),
        ],
      );
    }, error: (error, e) {
      return Center(
        child: Text(e.toString()),
      );
    }, loading: () {
      return const Center(
        child:
            SizedBox(width: 30, height: 30, child: CircularProgressIndicator()),
      );
    });
  }

  Widget _menuDropDown(List<MenuModel> menus) {
    List<DropdownMenuItem<int>> items;
    items = menus.map(((e) {
      return DropdownMenuItem<int>(
        value: e.MenuID,
        child: Text(e.MenuName ?? ''),
      );
    })).toList();
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: red,
        borderRadius: BorderRadius.circular(Spacing.sm),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: DropdownButton(
          isDense: true,
          borderRadius: BorderRadius.circular(Spacing.sm),
          value: selectedMenuIndex,
          items: items,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
          ),
          underline: Container(),
          onChanged: (int? value) {
            ref.read(menuIDProvider.notifier).state = value ?? 0;

            setState(() {
              selectedMenuIndex = value ?? 0;
            });
          },
          selectedItemBuilder: (BuildContext context) {
            return menus.map((e) {
              return Center(
                child: Text(
                  e.MenuName ?? '',
                  style: bodyTextDarkStyle,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Spacing.sm),
        border: Border.all(width: 1, color: backgroundColorVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Empty',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (String value) {
                ref.read(menuIDSearchProvider.notifier).state = value;
                searchKeyword = value;
              },
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () {
              ref.read(menuIDSearchProvider.notifier).state = searchKeyword;
            },
            icon: Icon(
              Icons.search,
            ),
          ),
        ],
      ),
    );
  }
}
