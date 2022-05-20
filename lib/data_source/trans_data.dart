import 'package:flutter/material.dart';

import '../constants/text_style_constant.dart';
import '../model/trans_model.dart';

class TransData extends DataTableSource {
  @override
  DataRow? getRow(int index) {
    final TransModel item = trans[index];
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(
          item.rcptNo,
          style: bodyTextLightStyle,
        )),
        DataCell(Text(
          item.posID,
          style: bodyTextLightStyle,
        )),
        DataCell(Text(
          item.tableNo.toString(),
          style: bodyTextLightStyle,
        )),
        DataCell(Text(
          item.remarks,
          style: bodyTextLightStyle,
        )),
        DataCell(Text(
          item.firstOP,
          style: bodyTextLightStyle,
        )),
        DataCell(Text(
          item.total.toString(),
          style: bodyTextLightStyle,
        )),
        DataCell(Text(
          item.openDate,
          style: bodyTextLightStyle,
        )),
        DataCell(Text(
          item.time,
          style: bodyTextLightStyle,
        )),
        DataCell(Text(
          item.split.toString(),
          style: bodyTextLightStyle,
        )),
        DataCell(Text(
          item.opNo.toString(),
          style: bodyTextLightStyle,
        )),
        DataCell(Text(
          item.tableStatus,
          style: bodyTextLightStyle,
        )),
        DataCell(Text(
          item.mode,
          style: bodyTextLightStyle,
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => trans.length;

  @override
  int get selectedRowCount => 0;
}
