import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/text_style_constant.dart';
import '../model/order_model.dart';
import '../model/theme_model.dart';

class OrderData extends DataTableSource {
  @override
  DataRow? getRow(int index) {
    OrderItemModel item = orderItems[index];
    return DataRow(
      cells: <DataCell>[
        DataCell(Consumer<ThemeModel>(builder:
            (BuildContext context, ThemeModel themeNotifier, Widget? child) {
          return Text(
            item.qty.toString(),
            style:
                themeNotifier.isDark ? bodyTextDarkStyle : bodyTextLightStyle,
          );
        })),
        DataCell(Consumer<ThemeModel>(builder:
            (BuildContext context, ThemeModel themeNotifier, Widget? child) {
          return Text(
            item.description,
            style:
                themeNotifier.isDark ? bodyTextDarkStyle : bodyTextLightStyle,
          );
        })),
        DataCell(Consumer<ThemeModel>(builder:
            (BuildContext context, ThemeModel themeNotifier, Widget? child) {
          return Text(
            item.amount.toString(),
            style:
                themeNotifier.isDark ? bodyTextDarkStyle : bodyTextLightStyle,
          );
        })),
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
