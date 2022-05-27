import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/text_style_constant.dart';
import '../../home/model/order_model.dart';

class OrderData extends DataTableSource {
  final bool isDark;
  OrderData(this.isDark);

  @override
  DataRow? getRow(int index) {
    OrderItemModel item = orderItems[index];
    return DataRow(
      cells: <DataCell>[
        DataCell(
          Text(
            item.qty.toString(),
            style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
          ),
        ),
        DataCell(
          Text(
            item.description,
            style: isDark ? bodyTextDarkStyle : bodyTextLightStyle,
          ),
        ),
        DataCell(
          Text(
            item.amount.toString(),
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
