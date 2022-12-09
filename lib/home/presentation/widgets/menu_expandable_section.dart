import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/home/model/menu_item_model.dart';
import 'package:raptorpos/home/model/menu_model.dart';
import 'package:raptorpos/home/presentation/widgets/menu_item_card.dart';

class MenuExpandableSection extends ConsumerStatefulWidget {
  MenuExpandableSection({Key? key, required this.menu, required this.menuItems})
      : super(key: key);

  final MenuModel menu;
  final List<MenuItemModel> menuItems;

  @override
  _MenuExpandableSectionState createState() => _MenuExpandableSectionState();
}

class _MenuExpandableSectionState extends ConsumerState<MenuExpandableSection> {
  late MenuModel _menu;
  late List<MenuItemModel> _menuItems;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _menu = widget.menu;
    _menuItems = widget.menuItems;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_menu.MenuName ?? ''),
            IconButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: _isExpanded
                  ? Icon(Icons.keyboard_arrow_down)
                  : Icon(Icons.keyboard_arrow_up),
            ),
          ],
        ),
        _menuItems.isEmpty
            ? Container()
            : !_isExpanded
                ? Container()
                : Responsive(
                    mobile: ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider();
                      },
                      physics: ClampingScrollPhysics(),
                      itemCount: _menuItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        final MenuItemModel item = _menuItems[index];

                        return GestureDetector(
                          onTap: () {},
                          child: MenuItemCard(
                            null,
                            menuItem: item,
                          ),
                        );
                      },
                    ),
                    tablet: GridView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: _menuItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisExtent:
                            Responsive.isMobile(context) ? 80.h : 90.h,
                        crossAxisSpacing: Spacing.sm,
                        mainAxisSpacing: Spacing.sm,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final MenuItemModel item = _menuItems[index];

                        return GestureDetector(
                          onTap: () {},
                          child: MenuItemCard(
                            null,
                            menuItem: item,
                          ),
                        );
                      },
                    ),
                    desktop: GridView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: _menuItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisExtent:
                            Responsive.isMobile(context) ? 80.h : 90.h,
                        crossAxisSpacing: Spacing.sm,
                        mainAxisSpacing: Spacing.sm,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final MenuItemModel item = _menuItems[index];

                        return GestureDetector(
                          onTap: () {},
                          child: MenuItemCard(
                            null,
                            menuItem: item,
                          ),
                        );
                      },
                    ),
                  )
      ],
    );
  }
}
