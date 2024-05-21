import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/extension/color_extension.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/presentation/widgets/menu_item_detail.dart';
import 'package:raptorpos/theme/theme_state_notifier.dart';

import '../../model/menu_item_model.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/text_style_constant.dart';

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

class MenuItemCard extends ConsumerStatefulWidget {
  final MenuItemModel menuItem;
  final OrderItemModel? orderItem;
  MenuItemCard(this.orderItem, {required this.menuItem, Key? key})
      : super(key: key);

  @override
  _MenuItemCardState createState() => _MenuItemCardState();
}

class _MenuItemCardState extends ConsumerState<MenuItemCard> {
  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierColor: Colors.black38,
          barrierLabel: 'Label',
          barrierDismissible: true,
          pageBuilder: (_, __, ___) => MenuItemDetail(
            widget.menuItem.pluNumber ?? '',
            0,
            false,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: HexColor(widget.menuItem.color ?? 'ffffff').withOpacity(0.4),
          border: Border.all(
            color: isDark ? backgroundDarkColor : Colors.green.shade100,
          ),
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isDark ? backgroundDarkColor : Colors.green.shade100,
              spreadRadius: 1.0,
              blurRadius: 2.0,
            ),
          ],
        ),
        child: Center(
          child: Text(widget.menuItem.itemName ?? '',
              textAlign: TextAlign.center,
              style: isDark
                  ? bodyTextDarkStyle
                  : bodyTextLightStyle.copyWith(color: Colors.black)),
        ),
      ),
    );
  }
}
