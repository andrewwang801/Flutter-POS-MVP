import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:raptorpos/common/GlobalConfig.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/presentation/widgets/menu_item_detail.dart';

import '../../constants/text_style_constant.dart';

class OrderData extends DataTableSource {
  final BuildContext context;
  final bool isDark;
  final List<OrderItemModel> orderItems;
  OrderData(this.isDark, this.orderItems, this.context);

  @override
  DataRow? getRow(int index) {
    OrderItemModel item = orderItems[index];
    late double subTotal =
        item.FOCItem == 1 ? 0 : (item.ItemAmount ?? 0) * (item.Quantity ?? 1);
    return DataRow(
      onSelectChanged: (_value) {
        showGeneralDialog(
          context: context,
          barrierColor: Colors.black38,
          barrierLabel: 'Order Item',
          barrierDismissible: true,
          pageBuilder: (_, __, ___) => MenuItemDetail(
              orderItems[index].PLUNo ?? '', item.PLUSalesRef ?? 0, true),
        );
      },
      cells: <DataCell>[
        DataCell(
          Container(
            width: 50.w,
            child: Text(
              ((item.Preparation ?? 0) == 0) ? item.Quantity.toString() : '',
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
            ),
          ),
        ),
        DataCell(
          Container(
            width: 150.w,
            child: Text(
              item.ItemName ?? '',
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
            ),
          ),
        ),
        DataCell(
          Container(
            width: 70.w,
            child: Text(
              ((item.Preparation ?? 0) == 0) ? subTotal.toString() : '',
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
            ),
          ),
        ),
        DataCell(
          Container(
            width: 70.w,
            child: Text(
              ((item.Preparation ?? 0) == 0) ? item.CategoryId.toString() : '',
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
            ),
          ),
        ),
        DataCell(
          Container(
            width: 70.w,
            child: Text(
              ((item.Preparation ?? 0) == 0) ? item.PaidAmount.toString() : '',
              style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => orderItems.length;

  @override
  int get selectedRowCount => 0;
}
