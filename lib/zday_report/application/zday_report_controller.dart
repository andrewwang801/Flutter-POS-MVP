import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../../common/utils/datetime_util.dart';
import '../../common/utils/strings_util.dart';
import '../../common/utils/type_util.dart';
import '../../common/widgets/dash_line.dart';
import '../../constants/dimension_constant.dart';
import '../../print/provider/print_controller.dart';
import '../domain/report_local_repository.dart';
import 'zday_report_state.dart';

@Injectable()
class ZDayReportController extends StateNotifier<ZDayReportState>
    with TypeUtil, DateTimeUtil, StringUtil {
  ZDayReportController(this.reportRepository,
      {@factoryParam required this.printController})
      : super(const ZDayReportState());

  final ReportLocalRepository reportRepository;
  final PrintController printController;

  Future<void> fetchZDay() async {
    try {
      state = const ZDayReportState(workable: Workable.loading);

      final List<List<String>> lastZDayArr =
          await reportRepository.getLastZDayDate(POSDtls.deviceNo);
      if (lastZDayArr.isNotEmpty) {
        String lastZDayDt = lastZDayArr[0][3];
        lastZDayDt = lastZDayDt.substring(0, 10);

        String lastZDayTime = lastZDayArr[0][4];
        lastZDayTime = lastZDayTime.substring(11);

        final String lastZDay = '$lastZDayDt $lastZDayTime';
        final String currDate = currentDateTime('yyyy-MM-dd HH:mm:ss.0');
        date1 = lastZDay;
        date2 = currDate;

        final DateTime zDayDate = DateTime.parse(lastZDay);
        final String currentDate = currentDateTime('dd/MM/yyyy HH:mm:ss');
        final String lastZDayDate =
            dateToString(zDayDate, 'dd/MM/yyyy HH:mm:ss');

        zDayReportNo = lastZDayArr[0][6].toInt();
        final String zDayStr =
            await generateZDay(lastZDay, currDate, currentDate, lastZDayDate);

        // state ready
        state = state.copyWith(
            workable: Workable.ready,
            data: Data(zDayReport: zDayStr, zDayWidgets: zDayWidgets));
      }
    } catch (e) {
      state = state.copyWith(
          workable: Workable.failure, failure: Failure(errMsg: e.toString()));
    }
  }

  int countSalesData = 0;
  String zDayPrint = '';
  int zDayReportNo = 0;
  String date1 = '', date2 = '';
  List<Widget> zDayWidgets = <Widget>[];
  Future<String> generateZDay(String date1, String date2, String currentDate,
      String lastZDayDate) async {
    zDayWidgets = [];
    zDayPrint = '';
    await reportRepository.salesReport(date1, date2, POSDtls.deviceNo);
    await reportRepository.transaction(date1, date2, POSDtls.deviceNo);

    double iSalesQty = 0,
        iSalesAmt = 0,
        iDiscQty = 0,
        iDiscAmt = 0,
        billDiscQty = 0,
        billDiscAmt = 0,
        iFOCQty = 0,
        iFOCAmt = 0,
        BFOCQty = 0,
        BFOCAmt = 0;
    double PSAmt = 0,
        PSQty = 0,
        PIDQty = 0,
        PIDAmt = 0,
        PBDQty = 0,
        PBDAmt = 0,
        PFQty = 0,
        PFAmt = 0;
    int TBill = 0, TCover = 0;
    double Tax0 = 0,
        Tax1 = 0,
        Tax2 = 0,
        Tax3 = 0,
        Tax4 = 0,
        Tax5 = 0,
        Tax6 = 0,
        Tax7 = 0,
        Tax8 = 0,
        Tax9 = 0,
        TotalTax = 0,
        EstSales = 0;

    String zdaydatestr = currentDateTime('dd-MM-yyyy HH:mm');
    String ZDayStr = '';

    List<List<String>> SalesDataArr =
        await reportRepository.getSalesData(POSDtls.deviceNo);
    countSalesData = SalesDataArr.length;
    List<List<String>> TransArr =
        await reportRepository.getSalesTrans(POSDtls.deviceNo);
    List<List<String>> TotMediaArr =
        await reportRepository.getTotalTrans(POSDtls.deviceNo);
    List<List<String>> RefundArr =
        await reportRepository.refundSummary(date1, date2);
    List<List<String>> VoidReport =
        await reportRepository.voidSummary(date1, date2);
    List<List<String>> PendingSalesArr =
        await reportRepository.getSalesPending(date1, date2);
    List<List<String>> EstSalesReport =
        await reportRepository.getTotalSales(date1, date2);

    if (PendingSalesArr.isNotEmpty) {
      if (PendingSalesArr[0][0].isNotEmpty) {
        PSQty = PendingSalesArr[0][0].toDouble();
        PSAmt = PendingSalesArr[0][1].toDouble();
        PIDQty = PendingSalesArr[0][2].toDouble();
        PIDAmt = PendingSalesArr[0][3].toDouble();
        PBDQty = PendingSalesArr[0][4].toDouble();
        PBDAmt = PendingSalesArr[0][5].toDouble();
        PFQty = PendingSalesArr[0][6].toDouble();
        PFAmt = PendingSalesArr[0][7].toDouble();
      }
    }

    if (SalesDataArr.isNotEmpty && TransArr.isNotEmpty) {
      iSalesQty = SalesDataArr[0][0].toDouble();
      iSalesAmt = SalesDataArr[0][1].toDouble();
      iDiscQty = SalesDataArr[0][2].toDouble();
      iDiscAmt = SalesDataArr[0][3].toDouble();
      billDiscQty = SalesDataArr[0][4].toDouble();
      billDiscAmt = SalesDataArr[0][5].toDouble();
      iFOCQty = SalesDataArr[0][6].toDouble();
      iFOCAmt = SalesDataArr[0][7].toDouble();
      BFOCQty = SalesDataArr[0][8].toDouble();
      BFOCAmt = SalesDataArr[0][9].toDouble();
      Tax0 = SalesDataArr[0][13].toDouble();
      Tax1 = SalesDataArr[0][14].toDouble();
      Tax2 = SalesDataArr[0][15].toDouble();
      Tax3 = SalesDataArr[0][16].toDouble();
      Tax4 = SalesDataArr[0][17].toDouble();
      Tax5 = SalesDataArr[0][18].toDouble();
      Tax6 = SalesDataArr[0][19].toDouble();
      Tax7 = SalesDataArr[0][20].toDouble();
      Tax8 = SalesDataArr[0][21].toDouble();
      Tax9 = SalesDataArr[0][22].toDouble();
      TotalTax = SalesDataArr[0][23].toDouble();
      TBill = SalesDataArr[0][24].toInt();
      TCover = SalesDataArr[0][25].toInt();
    }

    //Header
    ZDayStr += '${POSDtls.ScreenHeader1}\n';
    zDayWidgets.add(Text(POSDtls.ScreenHeader1));
    zDayPrint += '${textPrintFormat('N', 'L', '1')}${POSDtls.ScreenHeader1}\n';

    ZDayStr += '${POSDtls.ScreenHeader2}\n';
    zDayWidgets.add(Text(POSDtls.ScreenHeader2));
    zDayPrint += '${textPrintFormat('N', 'L', '1')}${POSDtls.ScreenHeader2}\n';

    ZDayStr += '${POSDtls.ScreenHeader3}\n';
    zDayWidgets.add(Text(POSDtls.ScreenHeader3));
    zDayPrint += '${textPrintFormat('N', 'L', '1')}${POSDtls.ScreenHeader3}\n';

    ZDayStr += 'Z Sales Day Report\n\n';
    zDayWidgets.add(const Text('Z Sales Day Report'));
    zDayPrint += '${textPrintFormat('N', 'L', '1')}Z Sales Day Report\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}\n';

    // Report No & Date
    String report = 'ReportNo: $zDayReportNo';
    ZDayStr += report;
    zDayPrint += textPrintFormat('N', 'L', '1') + report;

    ZDayStr +=
        ' ${addSpace(zdaydatestr, 38 - report.length - zdaydatestr.length)}\n';
    zDayWidgets.add(Row(
      children: [
        Expanded(child: Text(report)),
        Expanded(child: Text(zdaydatestr)),
      ],
    ));

    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}ReportNo: ${addSpace(zdaydatestr, 38 - report.length - zdaydatestr.length)}\n';

    // Add Dash Line
    ZDayStr += '${addDash(40)}\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}${addDash(40)}\n';
    // zDayWidgets.add(Text(addDash(40)));
    zDayWidgets.add(MySeparator());

    ZDayStr += 'Type                  Qty        Amount\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}Type                  Qty        Amount\n';

    ZDayStr += '${addDash(40)}\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}${addDash(40)}\n';

    // Add Items Heder and Dash Line
    zDayWidgets.add(Row(
      children: const <Widget>[
        Expanded(child: Text('Type')),
        Expanded(child: Text('Qty')),
        Expanded(child: Text('Amount'))
      ],
    ));
    // zDayWidgets.add(Text(addDash(40)));
    zDayWidgets.add(MySeparator());

    //Item Sales
    iSalesQty = iSalesQty + PSQty;
    String strISQty =
        addSpace(iSalesQty.toString(), 5 - iSalesQty.toString().length);

    iSalesAmt = iSalesAmt + PSAmt;
    String strISAmt = iSalesAmt.toString();
    if (iSalesAmt < 0) {
      strISAmt = strISAmt.substring(1);
      strISAmt = '( $strISAmt)';
    }
    zDayWidgets.add(Row(
      children: <Widget>[
        const Expanded(child: Text('Item Sales')),
        Expanded(child: Text('(+) $strISQty')),
        Expanded(child: Text(strISAmt))
      ],
    ));

    strISAmt = addSpace(strISAmt, 14 - strISAmt.length);

    ZDayStr += 'Item Sales      (+) $strISQty $strISAmt\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}Item Sales      (+) $strISQty $strISAmt\n';

    //Item Disc
    iDiscQty = iDiscQty + PIDQty;
    String strIDQty =
        addSpace(iDiscQty.toString(), 5 - iDiscQty.toString().length);

    iDiscAmt = iDiscAmt + PIDAmt;
    String strIDAmt = iDiscAmt.toString();

    if (iDiscAmt < 0) {
      strIDAmt = strIDAmt.substring(1);
      strIDAmt = '( $strIDAmt)';
    }
    zDayWidgets.add(Row(
      children: <Widget>[
        const Expanded(child: Text('Item Discount')),
        Expanded(child: Text('(-) $strISQty')),
        Expanded(child: Text(strIDAmt))
      ],
    ));

    strIDAmt = addSpace(strIDAmt, 14 - strIDAmt.length);

    ZDayStr += 'Item Discount   (-) $strIDQty $strIDAmt\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}Item Discount   (-) $strIDQty $strIDAmt\n';

    //Bill Disc
    billDiscQty = billDiscQty + PBDQty;
    String strBDQty =
        addSpace(billDiscQty.toString(), 5 - billDiscQty.toString().length);

    billDiscAmt = billDiscAmt + PBDAmt;
    String strBDAmt = billDiscAmt.toString();

    if (billDiscAmt < 0) {
      strBDAmt = strBDAmt.substring(1);
      strBDAmt = '( $strBDAmt)';
    }
    zDayWidgets.add(Row(
      children: <Widget>[
        const Expanded(child: Text('Bill Discount')),
        Expanded(child: Text('(-) $strBDQty')),
        Expanded(child: Text(strBDAmt))
      ],
    ));

    strBDAmt = addSpace(strBDAmt, 14 - strBDAmt.length);

    ZDayStr += 'Bill Discount   (-) $strBDQty $strBDAmt\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}Bill Discount   (-) $strBDQty $strBDAmt\n';

    //Item FOC
    iFOCQty = iFOCQty + PFQty;
    String strIFOCQty =
        addSpace(iFOCQty.toString(), 5 - iFOCQty.toString().length);

    iFOCAmt = iFOCAmt + PFAmt;
    String strIFOCAmt = iFOCAmt.toString();

    if (iFOCAmt < 0) {
      strIFOCAmt = strIFOCAmt.substring(1);
      strIFOCAmt = '( $strIFOCAmt)';
    }
    zDayWidgets.add(Row(
      children: <Widget>[
        const Expanded(child: Text('FOC Items')),
        Expanded(child: Text('(-) $strIFOCQty')),
        Expanded(child: Text(strIFOCAmt))
      ],
    ));

    strIFOCAmt = addSpace(strIFOCAmt, 14 - strIFOCAmt.length);

    ZDayStr += 'FOC Items       (-) $strIFOCQty $strIFOCAmt\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}FOC Items       (-) $strIFOCQty $strIFOCAmt\n';

    //Bill FOC
    String strBFOCQty =
        addSpace(BFOCQty.toString(), 5 - BFOCQty.toString().length);
    String strBFOCAmt = BFOCAmt.toString();

    if (BFOCAmt < 0) {
      strBFOCAmt = strBFOCAmt.substring(1);
      strBFOCAmt = '( $strBFOCAmt)';
    }
    zDayWidgets.add(Row(
      children: <Widget>[
        const Expanded(child: Text('FOC Bill')),
        Expanded(child: Text('(-) $strBFOCQty')),
        Expanded(child: Text(strBFOCAmt))
      ],
    ));

    strBFOCAmt = addSpace(strBFOCAmt, 14 - strBFOCAmt.length);

    ZDayStr += 'FOC Bill        (-) $strBFOCQty $strBFOCAmt\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}FOC Bill        (-) $strBFOCQty $strBFOCAmt\n';

    //Total & Est Sales
    double TotalSales = iSalesAmt - iDiscAmt - billDiscAmt - iFOCAmt - BFOCAmt;
    if (EstSalesReport.isNotEmpty) {
      EstSales = EstSalesReport[0][0].toDouble();
    }

    if (TotalSales > 0) {
      String strTotalSales = TotalSales.toString();
      strTotalSales = addSpace(strTotalSales, 19 - strTotalSales.length);

      ZDayStr += '\nTotal Sales     (=)  $strTotalSales\n';
      zDayPrint += '${textPrintFormat('N', 'L', '1')}\n';
      zDayPrint +=
          '${textPrintFormat('N', 'L', '1')}Total Sales     (=)  $strTotalSales\n';
      zDayWidgets.add(Row(
        children: [
          Expanded(child: Text('Total Sales')),
          Expanded(child: Text('$TotalSales')),
        ],
      ));

      strTotalSales = EstSales.toString();
      strTotalSales = addSpace(strTotalSales, 19 - strTotalSales.length);

      ZDayStr += 'Estimated Sales      $strTotalSales\n';
      zDayPrint +=
          '${textPrintFormat('N', 'L', '1')}Estimated Sales      $strTotalSales\n';
      zDayWidgets.add(Row(
        children: [
          Expanded(child: Text('Estimated Sales')),
          Expanded(child: Text('$EstSales')),
        ],
      ));
    }

    //Media
    ZDayStr += '-----------------MEDIA------------------\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}-----------------MEDIA------------------\n';
    zDayWidgets.add(verticalSpaceSmall);
    zDayWidgets.add(Center(
      child: Text(
        '----------------- MEDIA ------------------',
        textAlign: TextAlign.center,
      ),
    ));

    for (int i = 0; i < TransArr.length; i++) {
      String Title = TransArr[i][1];
      String strQty = TransArr[i][2];
      strQty = addSpace(strQty, 24 - Title.length - strQty.length);

      double TransAmt = TransArr[i][3].toDouble();
      String strAmt = TransAmt.toString();

      if (TransAmt < 0) {
        strAmt = strAmt.substring(1);
        strAmt = '( $strAmt)';
      }
      strAmt = addSpace(strAmt, 14 - strAmt.length);

      ZDayStr += '$Title $strQty $strAmt\n';
      zDayPrint += '${textPrintFormat('N', 'L', '1')}$Title $strQty $strAmt\n';
      zDayWidgets.add(Row(
        children: <Widget>[
          Expanded(child: Text('$TransArr[i][1]')),
          Expanded(child: Text('$TransArr[i][2]')),
          Expanded(child: Text('$TransAmt'))
        ],
      ));
    }

    ZDayStr += '\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}\n';

    //Total Media
    double TotQty = 0, TotCollection = 0;
    for (int i = 0; i < TotMediaArr.length; i++) {
      String Title = TotMediaArr[i][0];
      double TotMediaQty = TotMediaArr[i][1].toDouble();
      String strQty = TotMediaQty.toString();
      strQty = addSpace(strQty, 18 - Title.length - strQty.length);

      double TotMediaAmt = TotMediaArr[i][2].toDouble();
      String strAmt = TotMediaAmt.toString();

      if (TotMediaAmt < 0) {
        strAmt = strAmt.substring(1);
        strAmt = '( $strAmt)';
      }
      strAmt = addSpace(strAmt, 14 - strAmt.length);

      ZDayStr += 'TOTAL $Title $strQty $strAmt\n';
      zDayPrint +=
          '${textPrintFormat('N', 'L', '1')}TOTAL $Title $strQty $strAmt\n';
      zDayWidgets.add(Row(
        children: <Widget>[
          Expanded(child: Text('TOTAL')),
          Expanded(child: Text('$TotMediaArr[i][0]')),
          Expanded(child: Text('$TotMediaQty')),
          Expanded(child: Text('$TotMediaAmt'))
        ],
      ));

      TotQty += TotMediaQty;
      TotCollection += TotMediaAmt;
    }

    //Void Refund Summary
    ZDayStr += '----------VOID / REFUND SUMMARY---------\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}----------VOID / REFUND SUMMARY---------\n';
    zDayWidgets.add(verticalSpaceSmall);
    zDayWidgets
        .add(Center(child: Text('------- VOID / REFUND SUMMARY --------')));
    zDayWidgets.add(verticalSpaceSmall);

    double RefundQty = 0, RefundAmt = 0;
    if (RefundArr.isNotEmpty) {
      RefundQty = RefundArr[0][0].toDouble();
      RefundAmt = RefundArr[0][1].toDouble();
    }

    String strRQty = RefundQty.toString();
    strRQty = addSpace(strRQty, 18 - strRQty.length);

    String strRAmt = RefundAmt.toString();
    strRAmt = addSpace(strRAmt, 14 - strRAmt.length);

    ZDayStr += 'Refund $strRQty $strRAmt\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}Refund $strRQty $strRAmt\n';
    zDayWidgets.add(Row(
      children: <Widget>[
        Expanded(child: Text('Refund')),
        Expanded(child: Text('$RefundQty')),
        Expanded(child: Text('$RefundAmt')),
      ],
    ));

    double PreVoidQty = 0, PreVoidAmt = 0, PostVoidQty = 0, PostVoidAmt = 0;
    if (VoidReport.isNotEmpty) {
      PreVoidQty = VoidReport[0][0].toDouble();
      PreVoidAmt = VoidReport[0][1].toDouble();
      PostVoidQty = VoidReport[0][2].toDouble();
      PostVoidAmt = VoidReport[0][3].toDouble();
    }

    String strPrVQty = PreVoidQty.toString();
    strPrVQty = addSpace(strPrVQty, 11 - strPrVQty.length);

    String strPrVAmt = PreVoidAmt.toString();
    strPrVAmt = addSpace(strPrVAmt, 14 - strPrVAmt.length);

    ZDayStr += 'Pre-Send Void $strPrVQty $strPrVAmt\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}Pre-Send Void $strPrVQty $strPrVAmt\n';
    zDayWidgets.add(Row(
      children: <Widget>[
        Expanded(child: Text('Pre-Send Void')),
        Expanded(child: Text('$PreVoidQty')),
        Expanded(child: Text('$PreVoidAmt')),
      ],
    ));

    String strPoVQty = PreVoidQty.toString();
    strPoVQty = addSpace(strPoVQty, 10 - strPoVQty.length);

    String strPoVAmt = PreVoidAmt.toString();
    strPoVAmt = addSpace(strPoVAmt, 14 - strPoVAmt.length);

    ZDayStr += 'Post-Send Void $strPoVQty $strPoVAmt\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}Post-Send Void $strPoVQty $strPoVAmt\n';
    zDayWidgets.add(Row(
      children: <Widget>[
        Expanded(child: Text('Post-Send Void')),
        Expanded(child: Text('$PreVoidQty')),
        Expanded(child: Text('$PreVoidAmt')),
      ],
    ));

    ZDayStr += '${addDash(40)}\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}${addDash(40)}\n';
    // zDayWidgets.add(Text(addDash(40)));
    zDayWidgets.add(MySeparator());

    //Total Collection
    String strTotQty = TotQty.toString();
    strTotQty = addSpace(strTotQty, 8 - strTotQty.length);

    String strTotColl = TotCollection.toString();
    if (TotCollection < 0) {
      strTotColl = strTotColl.substring(1);
      strTotColl = '( $strTotColl)';
    }

    zDayWidgets.add(Row(
      children: <Widget>[
        Expanded(child: Text('Total Collection')),
        Expanded(child: Text('$TotQty')),
        Expanded(child: Text('$TotCollection')),
      ],
    ));

    strTotColl = addSpace(strTotColl, 14 - strTotColl.length);
    ZDayStr += 'Total Collection $strTotQty $strTotColl\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}Total Collection $strTotQty $strTotColl\n';

    //Tax
    if (TotalTax > 0) {
      ZDayStr += '------------------TAX-------------------\n';
      zDayPrint +=
          '${textPrintFormat('N', 'L', '1')}------------------TAX-------------------\n';
      zDayWidgets.add(Text('------------------TAX-------------------'));

      if (Tax0 > 0) {
        List<List<String>> TaxArray = await reportRepository.getTaxApplied('0');
        String TaxName = TaxArray[0][1];
        String strTax = Tax0.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ZDayStr += '$TaxName $strTax\n';
        zDayPrint += '${textPrintFormat('N', 'L', '1')}$TaxName $strTax\n';
        zDayWidgets.add(Row(
          children: <Widget>[
            Expanded(child: Text('$TaxArray[0][1]')),
            Expanded(child: Text('$Tax0')),
          ],
        ));
      }

      if (Tax1 > 0) {
        List<List<String>> TaxArray = await reportRepository.getTaxApplied('1');
        String TaxName = TaxArray[0][1];
        String strTax = Tax1.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ZDayStr += '$TaxName $strTax\n';
        zDayPrint += '${textPrintFormat('N', 'L', '1')}$TaxName $strTax\n';
        zDayWidgets.add(Row(
          children: <Widget>[
            Expanded(child: Text('$TaxArray[0][1]')),
            Expanded(child: Text('$Tax0')),
          ],
        ));
      }

      if (Tax2 > 0) {
        List<List<String>> TaxArray = await reportRepository.getTaxApplied('2');
        String TaxName = TaxArray[0][1];
        String strTax = Tax2.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ZDayStr += '$TaxName $strTax\n';
        zDayPrint += '${textPrintFormat('N', 'L', '1')}$TaxName $strTax\n';
        zDayWidgets.add(Row(
          children: <Widget>[
            Expanded(child: Text('$TaxArray[0][1]')),
            Expanded(child: Text('$Tax0')),
          ],
        ));
      }

      if (Tax3 > 0) {
        List<List<String>> TaxArray = await reportRepository.getTaxApplied('3');
        String TaxName = TaxArray[0][1];
        String strTax = Tax3.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ZDayStr += '$TaxName $strTax\n';
        zDayPrint += '${textPrintFormat('N', 'L', '1')}$TaxName $strTax\n';
        zDayWidgets.add(Row(
          children: <Widget>[
            Expanded(child: Text('$TaxArray[0][1]')),
            Expanded(child: Text('$Tax0')),
          ],
        ));
      }

      if (Tax4 > 0) {
        List<List<String>> TaxArray = await reportRepository.getTaxApplied('4');
        String TaxName = TaxArray[0][1];
        String strTax = Tax4.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ZDayStr += '$TaxName $strTax\n';
        zDayPrint += '${textPrintFormat('N', 'L', '1')}$TaxName $strTax\n';
        zDayWidgets.add(Row(
          children: <Widget>[
            Expanded(child: Text('$TaxArray[0][1]')),
            Expanded(child: Text('$Tax0')),
          ],
        ));
      }

      if (Tax5 > 0) {
        List<List<String>> TaxArray = await reportRepository.getTaxApplied('5');
        String TaxName = TaxArray[0][1];
        String strTax = Tax5.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ZDayStr += '$TaxName $strTax\n';
        zDayPrint += '${textPrintFormat('N', 'L', '1')}$TaxName $strTax\n';
        zDayWidgets.add(Row(
          children: <Widget>[
            Expanded(child: Text('$TaxArray[0][1]')),
            Expanded(child: Text('$Tax0')),
          ],
        ));
      }

      if (Tax6 > 0) {
        List<List<String>> TaxArray = await reportRepository.getTaxApplied('6');
        String TaxName = TaxArray[0][1];
        String strTax = Tax6.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ZDayStr += '$TaxName $strTax\n';
        zDayPrint += '${textPrintFormat('N', 'L', '1')}$TaxName $strTax\n';
        zDayWidgets.add(Row(
          children: <Widget>[
            Expanded(child: Text('$TaxArray[0][1]')),
            Expanded(child: Text('$Tax0')),
          ],
        ));
      }

      if (Tax7 > 0) {
        List<List<String>> TaxArray = await reportRepository.getTaxApplied('7');
        String TaxName = TaxArray[0][1];
        String strTax = Tax7.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ZDayStr += '$TaxName $strTax\n';
        zDayPrint += '${textPrintFormat('N', 'L', '1')}$TaxName $strTax\n';
        zDayWidgets.add(Row(
          children: <Widget>[
            Expanded(child: Text('$TaxArray[0][1]')),
            Expanded(child: Text('$Tax0')),
          ],
        ));
      }

      if (Tax8 > 0) {
        List<List<String>> TaxArray = await reportRepository.getTaxApplied('8');
        String TaxName = TaxArray[0][1];
        String strTax = Tax8.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ZDayStr += '$TaxName $strTax\n';
        zDayPrint += '${textPrintFormat('N', 'L', '1')}$TaxName $strTax\n';
        zDayWidgets.add(Row(
          children: <Widget>[
            Expanded(child: Text('$TaxArray[0][1]')),
            Expanded(child: Text('$Tax0')),
          ],
        ));
      }

      if (Tax9 > 0) {
        List<List<String>> TaxArray = await reportRepository.getTaxApplied('9');
        String TaxName = TaxArray[0][1];
        String strTax = Tax9.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ZDayStr += '$TaxName $strTax\n';
        zDayPrint += '${textPrintFormat('N', 'L', '1')}$TaxName $strTax\n';
        zDayWidgets.add(Row(
          children: <Widget>[
            Expanded(child: Text('$TaxArray[0][1]')),
            Expanded(child: Text('$Tax0')),
          ],
        ));
      }
    }

    ZDayStr += '${addDash(40)}\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}${addDash(40)}\n';
    // zDayWidgets.add(Text(addDash(40)));
    zDayWidgets.add(MySeparator());

    //Nett Sales
    String strNetSales = TotalSales.toString();
    if (TotalSales < 0) {
      strNetSales = strNetSales.substring(1);
      strNetSales = '( $strNetSales)';
    }
    zDayWidgets.add(Row(
      children: <Widget>[
        Expanded(child: Text('Net Sales')),
        Expanded(child: Text(strNetSales)),
      ],
    ));

    strNetSales = addSpace(strNetSales, 29 - strNetSales.length);

    ZDayStr += 'Nett Sales $strNetSales\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}Nett Sales $strNetSales\n';

    ZDayStr += '${addDash(40)}\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}${addDash(40)}\n';
    // zDayWidgets.add(Text(addDash(40)));
    zDayWidgets.add(MySeparator());

    //Total Bill & Cover
    String strTBill = addSpace(TBill.toString(), 23 - TBill.toString().length);
    ZDayStr += 'Total # of Bills $strTBill\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}Total # of Bills $strTBill\n';
    zDayWidgets.add(Row(
      children: <Widget>[
        Expanded(child: Text('Total # of Bills')),
        Expanded(child: Text('$TBill')),
      ],
    ));

    String strTCover =
        addSpace(TCover.toString(), 23 - TCover.toString().length);
    ZDayStr += 'Total # of Bills $strTCover\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}Total # of Bills $strTCover\n';
    zDayWidgets.add(Row(
      children: <Widget>[
        Expanded(child: Text('Total # of Bills')),
        Expanded(child: Text('$TCover')),
      ],
    ));

    ZDayStr += '${addDash(40)}\n';
    ZDayStr += '${addDash(40)}\n\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}${addDash(40)}\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}${addDash(40)}\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}\n';
    // zDayWidgets.add(Text(addDash(40)));
    // zDayWidgets.add(Text(addDash(40)));
    zDayWidgets.add(MySeparator());
    zDayWidgets.add(MySeparator());

    //Rcpt No
    List<List<String>> RcptNoArr =
        await reportRepository.getReceiptNo(date1, date2);
    if (RcptNoArr.isNotEmpty) {
      String RcptBegin = RcptNoArr[0][0];
      RcptBegin = addSpace(RcptBegin, 25 - RcptBegin.length);
      String RcptEnd = RcptNoArr[0][1];
      RcptEnd = addSpace(RcptEnd, 27 - RcptEnd.length);

      ZDayStr += 'Begin Receipt# $RcptBegin\n';
      ZDayStr += 'End Receipt# $RcptEnd\n\n\n';

      zDayWidgets.add(Row(
        children: <Widget>[
          Expanded(child: Text('Begin Receipt#')),
          Expanded(child: Text('${RcptNoArr[0][0]}')),
        ],
      ));
      zDayWidgets.add(Row(
        children: <Widget>[
          Expanded(child: Text('End Receipt#')),
          Expanded(child: Text('${RcptNoArr[0][1]}')),
        ],
      ));

      zDayPrint +=
          '${textPrintFormat('N', 'L', '1')}Begin Receipt# $RcptBegin\n';
      zDayPrint += '${textPrintFormat('N', 'L', '1')}End Receipt# $RcptEnd\n';
      zDayPrint += '${textPrintFormat('N', 'L', '1')}\n';
      zDayPrint += '${textPrintFormat('N', 'L', '1')}\n';
    } else {
      String RcptBegin = 'A00000000000';
      RcptBegin = addSpace(RcptBegin, 25 - RcptBegin.length);
      String RcptEnd = 'A00000000000';
      RcptEnd = addSpace(RcptEnd, 27 - RcptEnd.length);

      ZDayStr += 'Begin Receipt# $RcptBegin\n';
      ZDayStr += 'End Receipt# $RcptEnd\n\n\n';

      zDayWidgets.add(Row(
        children: <Widget>[
          Expanded(child: Text('Begin Receipt#')),
          Expanded(child: Text('${RcptNoArr[0][0]}')),
        ],
      ));
      zDayWidgets.add(Row(
        children: <Widget>[
          Expanded(child: Text('End Receipt#')),
          Expanded(child: Text('${RcptNoArr[0][1]}')),
        ],
      ));

      zDayPrint +=
          '${textPrintFormat('N', 'L', '1')}Begin Receipt# $RcptBegin\n';
      zDayPrint += '${textPrintFormat('N', 'L', '1')}End Receipt# $RcptEnd\n';
      zDayPrint += '${textPrintFormat('N', 'L', '1')}\n';
      zDayPrint += '${textPrintFormat('N', 'L', '1')}\n';
    }

    ZDayStr += '========================================\n';
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}========================================\n';
    zDayWidgets.add(Text('=============================='));

    ZDayStr += '$lastZDayDate-$currentDate\n\n';
    zDayWidgets.add(Text('$lastZDayDate-$currentDate'));
    zDayPrint +=
        '${textPrintFormat('N', 'L', '1')}$lastZDayDate-$currentDate\n';
    zDayPrint += '${textPrintFormat('N', 'L', '1')}\n';

    return ZDayStr;
  }

  Future<void> doZDay() async {
    try {
      int SalesData = await reportRepository.checkData();
      if (SalesData == 0) {
        if (countSalesData > 0) {
          await reportRepository.zDayItemSummary(
              zDayReportNo, date1, date2, POSDtls.deviceNo);
          await reportRepository.zDayCollectionSummary(
              zDayReportNo, POSDtls.deviceNo);
          await reportRepository.zDaySalesSummary(
              zDayReportNo, date1, date2, POSDtls.deviceNo);

          zDayReportNo += 1;
          await reportRepository.doZDaySales(zDayReportNo, POSDtls.deviceNo);
          // GameObject.Find("OnlineController").GetComponent<OnlineFunction>().SendZDay();
        }

        // GameObject.Find("MainController").GetComponent<MainController>().XZDayNotif(ZDayPrint);
        // Print, Set GlobalConfig.TableNoInt = POSDtls.AutoTblStart, SendSales
        await printController.doPrint(4, 0, zDayPrint);
        GlobalConfig.TableNoInt = POSDtls.AutoTblStart;
      } else {
        state = state.copyWith(
            failure: Failure(
                errMsg:
                    "Z-Report(Sales) Failed! You didn't finalized $SalesData Bill(s)"));
      }
    } catch (e) {
      state = state.copyWith(failure: Failure(errMsg: e.toString()));
    }
  }
}
