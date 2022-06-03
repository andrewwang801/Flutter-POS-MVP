import 'package:flutter/material.dart';
import 'package:raptorpos/home/model/order_item_model.dart';

import '../../constants/text_style_constant.dart';

class OrderData extends DataTableSource {
  final bool isDark;
  final List<OrderItemModel> orderItems;
  OrderData(this.isDark, this.orderItems);

  @override
  DataRow? getRow(int index) {
    OrderItemModel item = orderItems[index];
    return DataRow(
      cells: <DataCell>[
        DataCell(
          Text(
            item.Quantity.toString(),
            style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
          ),
        ),
        DataCell(
          Text(
            item.ItemName ?? '',
            style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
          ),
        ),
        DataCell(
          Text(
            item.ItemAmount.toString(),
            style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
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
