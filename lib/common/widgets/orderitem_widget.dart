// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raptorpos/common/widgets/orderitem_interface.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/home/presentation/widgets/menu_item_detail.dart';

import '../../constants/text_style_constant.dart';
import '../../home/model/order_item_model.dart';

@immutable
class ParentOrderItemWidget extends StatelessWidget implements IOrderItem {
  ParentOrderItemWidget({required this.orderItem, required this.isDark});

  final OrderItemModel orderItem;
  final List<IOrderItem> children = [];

  bool detail = false;
  int level = 0;
  final bool isDark;

  void addChild(IOrderItem child) {
    child.parent = this;
    children.add(child);
  }

  @override
  Widget render(
      BuildContext context, int padding, bool isDark, void Function() callback,
      {bool detail = false}) {
    level = (orderItem.Preparation ?? 0) == 1 ? 1 : 0;
    TextStyle textStyle =
        listItemTextDarkStyle.copyWith(fontSize: modifierItemFontSize);
    if (level != 0) {
      textStyle = listItemTextDarkStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: modifierItemFontSize,
          fontStyle: FontStyle.italic,
          color: Colors.grey);
    }
    return GestureDetector(
      onLongPress: () {
        showGeneralDialog(
          context: context,
          barrierColor: Colors.black38,
          barrierLabel: 'Label',
          barrierDismissible: true,
          pageBuilder: (_, __, ___) => MenuItemDetail(
            orderItem.PLUNo ?? '',
            orderItem.SalesRef ?? 0,
            true,
            orderItem: orderItem,
          ),
        );
      },
      child: Dismissible(
        onDismissed: (DismissDirection direction) {
          callback();
        },
        direction: DismissDirection.endToStart,
        key: UniqueKey(),
        background: Container(
          color: Colors.red,
        ),
        secondaryBackground: Container(
          color: Colors.red,
          child: Center(
            child: Text(
              'Delete',
              style: textStyle,
            ),
          ),
        ),
        child: Theme(
          data: ThemeData().copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ListTileTheme(
            contentPadding: EdgeInsets.zero,
            dense: true,
            child: ExpansionTile(
              title: Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "${orderItem.Quantity}",
                        textAlign: TextAlign.left,
                        style: isDark
                            ? textStyle
                            : textStyle.copyWith(color: Colors.black),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Row(children: [
                        SizedBox(
                          width: level * 20,
                        ),
                        Expanded(
                          child: Text(
                            orderItem.ItemName ?? '',
                            textAlign: TextAlign.left,
                            style: isDark
                                ? textStyle
                                : textStyle.copyWith(color: Colors.black),
                          ),
                        ),
                      ]),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text(
                          '${orderItem.ItemAmount}',
                          textAlign: TextAlign.left,
                          style: isDark
                              ? textStyle
                              : textStyle.copyWith(color: Colors.black),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text(
                          '${orderItem.CategoryId}',
                          textAlign: TextAlign.left,
                          style: isDark
                              ? textStyle
                              : textStyle.copyWith(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: children.isEmpty
                  ? const SizedBox(
                      width: 20,
                    )
                  : const SizedBox(
                      width: 20, child: Icon(Icons.arrow_drop_down_sharp)),
              initiallyExpanded: false,
              children: children
                  .map((IOrderItem child) =>
                      child.render(context, 0, isDark, callback))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  IOrderItem? parent;
}
