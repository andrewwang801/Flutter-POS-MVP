// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:get/get.dart';
import 'package:raptorpos/common/widgets/orderitem_interface.dart';
import 'package:raptorpos/constants/dimension_constant.dart';

import '../../constants/text_style_constant.dart';
import '../../home/model/order_item_model.dart';

class ParentOrderItemWidget extends StatelessWidget implements IOrderItem {
  final OrderItemModel orderItem;
  final List<IOrderItem> children = [];

  bool detail = false;
  int level = 0;

  ParentOrderItemWidget({required this.orderItem});

  void addChild(IOrderItem child) {
    child.parent = this;
    children.add(child);
  }

  @override
  Widget render(BuildContext context, int padding, {bool detail = false}) {
    level = (orderItem.Preparation ?? 0) == 1 ? 1 : 0;
    TextStyle textStyle =
        bodyTextDarkStyle.copyWith(fontSize: modifierItemFontSize);
    if (level != 0) {
      textStyle = bodyTextDarkStyle.copyWith(
          fontWeight: FontWeight.w300,
          fontSize: modifierItemFontSize,
          fontStyle: FontStyle.italic,
          color: Colors.grey);
    }
    return GestureDetector(
      onLongPress: () {
        // Get.to(
        //   ProgressHUD(
        //       child: ,
        //       barrierEnabled: false),
        // );
      },
      child: Dismissible(
        onDismissed: (DismissDirection direction) {},
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
                        style: textStyle,
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Row(children: [
                        SizedBox(
                          width: level * 20,
                        ),
                        Expanded(
                          child: Text(orderItem.ItemName ?? '',
                              textAlign: TextAlign.left, style: textStyle),
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
                          style: textStyle,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text(
                          '${orderItem.CategoryId}',
                          textAlign: TextAlign.left,
                          style: textStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: children.isEmpty
                  ? SizedBox(
                      width: 20,
                    )
                  : SizedBox(
                      width: 20, child: Icon(Icons.arrow_drop_down_sharp)),
              children:
                  children.map((child) => child.render(context, 0)).toList(),
              initiallyExpanded: false,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return render(context, 5, detail: detail);
  }

  @override
  IOrderItem? parent;
}
