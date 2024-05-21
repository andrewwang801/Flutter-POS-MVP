// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:raptorpos/common/widgets/orderitem_interface.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/home/model/order_mod_model.dart';
import 'package:raptorpos/home/model/order_prep_model.dart';
import 'package:raptorpos/home/presentation/widgets/menu_item_detail.dart';

import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../home/model/order_item_model.dart';
import '../GlobalConfig.dart';

@immutable
class ParentOrderItemWidget extends StatelessWidget implements IOrderItem {
  ParentOrderItemWidget(
      {required this.orderItem,
      required this.isDark,
      this.orderModList,
      this.orderPrepList});

  final OrderItemModel orderItem;
  final List<OrderModData>? orderModList;
  final List<OrderPrepModel>? orderPrepList;
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
    BuildContext context,
    int padding,
    bool isDark,
    void Function() callback, {
    bool detail = false,
    bool selected = false,
  }) {
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

    return Dismissible(
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
      child: Column(
        children: [
          OrderItemRowWidget(isDark, textStyle, selected, callback),
          ...prepWidgets(orderPrepList ?? []),
          ...modWidgets(orderModList ?? []),
        ],
      ),
    );
  }

  Widget OrderItemRowWidget(bool isDark, TextStyle textStyle, bool selected,
      void Function() callback) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
          color: (isDark ? primaryDarkColor : Colors.white),
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
                    categoryType(orderItem.CategoryId!),
                    textAlign: TextAlign.left,
                    style: isDark
                        ? textStyle
                        : textStyle.copyWith(color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      callback();
                    },
                  )),
            ],
          ),
        ),
        if (selected)
          Container(
            width: 3,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.green,
            ),
          ),
      ],
    );
  }

  List<Widget> prepWidgets(List<OrderPrepModel> preps) {
    return preps.map((e) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  e.prepQuantity.toInt().toString(),
                )),
            Expanded(
                flex: 7,
                child: Text(
                  '${e.prepName}',
                )),
            Expanded(
              flex: 5,
              child: Container(),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> modWidgets(List<OrderModData> mods) {
    return mods.map((e) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Container(
                  child: Text('1'),
                )),
            Expanded(
                flex: 7,
                child: Text(
                  'Modifier : ${e.modName}',
                )),
            Expanded(flex: 3, child: Container()),
            Expanded(flex: 2, child: Container()),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  String categoryType(int id) {
    if (id == 1) {
      return 'Take Away';
    } else if (id == 3) {
      return 'DINE IN';
    } else {
      return 'Delivery';
    }
  }

  @override
  IOrderItem? parent;
}
