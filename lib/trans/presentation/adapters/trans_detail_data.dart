import 'package:flutter/material.dart';

import '../../../constants/text_style_constant.dart';
import '../../data/trans_detail_model.dart';

class TransDetailData extends DataTableSource {
  @override
  DataRow? getRow(int index) {
    TransDetailModel item = transDetails[index];
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(item.qty.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.itemName, style: bodyTextLightStyle)),
        DataCell(Text(item.amount.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.discType, style: bodyTextLightStyle)),
        DataCell(Text(item.disc.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.operator.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.prmnTyle, style: bodyTextLightStyle)),
        DataCell(Text(item.prmn.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.mode, style: bodyTextLightStyle)),
        DataCell(Text(item.status, style: bodyTextLightStyle)),
        DataCell(Text(item.stNo.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.memID.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.date, style: bodyTextLightStyle)),
        DataCell(Text(item.time, style: bodyTextLightStyle)),
        DataCell(Text(item.tblNo.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.opNo.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.transOpNo.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.points.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.depositID.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.rentalItem.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.focItem.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.covers.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.gratuity.toString(), style: bodyTextLightStyle)),
        DataCell(Text(item.posID)),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => transDetails.length;

  @override
  int get selectedRowCount => 0;
}
