// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart';
import 'package:raptorpos/common/widgets/orderitem_interface.dart';
import 'package:raptorpos/common/widgets/responsive.dart';
import 'package:raptorpos/constants/dimension_constant.dart';
import 'package:raptorpos/home/model/order_mod_model.dart';
import 'package:raptorpos/home/model/order_prep_model.dart';

import '../../constants/color_constant.dart';
import '../../constants/text_style_constant.dart';
import '../../home/model/order_item_model.dart';

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
    void Function() callback,
    void Function() editCallback, {
    bool detail = false,
    bool selected = false,
  }) {
    level = (orderItem.Preparation ?? 0) == 1 ? 1 : 0;
    TextStyle textStyle = bodyTextDarkStyle;

    if (level != 0) {
      textStyle = bodyTextDarkStyle.copyWith(
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
          OrderItemRowWidget(
              isDark, textStyle, selected, callback, editCallback, context),
          ...prepWidgets(orderPrepList ?? []),
          ...modWidgets(orderModList ?? []),
        ],
      ),
    );
  }

  Widget OrderItemRowWidget(
      bool isDark,
      TextStyle textStyle,
      bool selected,
      void Function() callback,
      void Function() editCallback,
      BuildContext context) {
    double iconSize = Responsive.isMobile(context) ? 24.h : 12.h;
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Responsive.isMobile(context) ? Spacing.sm : 0.0),
          // color: (isDark ? primaryDarkColor : Colors.white),
          child: Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: iconSize,
                  ),
                  onPressed: () {
                    callback();
                  },
                ),
              ),
              horizontalSpaceSmall,
              if (Responsive.isTablet(context))
                Expanded(
                  flex: 7,
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        '(${orderItem.Quantity})  ${orderItem.ItemName}',
                        textAlign: TextAlign.left,
                        style: isDark
                            ? textStyle
                            : textStyle.copyWith(color: Colors.black),
                      ),
                    ),
                  ]),
                ),
              if (Responsive.isTablet(context))
                Expanded(
                  flex: 2,
                  child: Text(
                    '${orderItem.ItemAmount}',
                    textAlign: TextAlign.left,
                    style: isDark
                        ? textStyle
                        : textStyle.copyWith(color: Colors.black),
                  ),
                ),
              if (Responsive.isMobile(context))
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '(${orderItem.Quantity})  ${orderItem.ItemName}',
                        textAlign: TextAlign.left,
                        style: isDark
                            ? textStyle
                            : textStyle.copyWith(color: Colors.black),
                      ),
                      verticalSpaceSmall,
                      Text(
                        '${orderItem.ItemAmount}',
                        textAlign: TextAlign.left,
                        style: isDark
                            ? textStyle
                            : textStyle.copyWith(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              IconButton(
                  onPressed: () {
                    editCallback();
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    color: purple,
                    size: iconSize,
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

  List<Widget> modWidgets(List<OrderModData> mods) {
    return mods.map((e) {
      return Container(
        child: Row(
          children: [
            SizedBox(
              width: 24.w,
            ),
            Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Modifier : ${e.modName}',
                  ),
                )),
            Spacer(flex: 2),
            SizedBox(
              width: 24.w,
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> prepWidgets(List<OrderPrepModel> preps) {
    return preps.map((e) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 3.0),
        child: Row(
          children: [
            SizedBox(
              width: 24.w,
            ),
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  ' (${e.prepQuantity.toInt().toString()}) ${e.prepName}',
                ),
              ),
            ),
            Spacer(flex: 2),
            SizedBox(
              width: 24.w,
            ),
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
