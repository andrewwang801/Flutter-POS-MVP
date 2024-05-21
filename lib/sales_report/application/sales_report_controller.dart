import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../../common/utils/datetime_util.dart';
import '../../common/utils/strings_util.dart';
import '../../common/utils/type_util.dart';
import '../../print/provider/print_controller.dart';
import '../../zday_report/domain/report_local_repository.dart';
import 'sales_report_state.dart';

@Injectable()
class SalesReportController extends StateNotifier<SalesReportState>
    with TypeUtil, DateTimeUtil, StringUtil {
  SalesReportController(this.reportRepository,
      {@factoryParam required this.printController})
      : super(const SalesReportState());

  final ReportLocalRepository reportRepository;
  final PrintController printController;

  /// Datebase date format yyyy-MM-dd, HH:mm:ss.0
  /// Date Format for Presentation dd/MM/yyyy, HH:mm:ss

  int tagTime = 0, hourTime = 0;
  String firstDate = '',
      lastDate = '',
      reportPrint = '',
      timeRep1 = '',
      timeRep2 = '',
      dateRep1 = '',
      dateRep2 = '';

  Future<void> fetchData() async {
    try {
      state = state.copyWith(workable: Workable.loading);

      final List<List<String>> lastZDayArr =
          await reportRepository.getLastZDayDate(POSDtls.deviceNo);
      if (lastZDayArr.isNotEmpty) {
        final String lastZDayDate = lastZDayArr[0][3];
        final String lastZDayTime = lastZDayArr[0][4];

        dateRep1 = lastZDayDate.substring(0, 10);
        timeRep1 = lastZDayTime.substring(11);
        firstDate = '$dateRep1 $timeRep1';

        final DateTime lastZDay = DateTime.parse(firstDate);

        dateRep2 = currentDateTime('yyyy-MM-dd');
        timeRep2 = currentDateTime('HH:mm:ss.0');
        lastDate = '$dateRep2 $timeRep2';

        final String date1 = dateToString(lastZDay, 'dd/MM/yyyy');
        final String time1 = dateToString(lastZDay, 'HH:mm:ss');

        final String date2 = currentDateTime('dd/MM/yyyy');
        final String time2 = currentDateTime('HH:mm:ss');

        final String salesReport =
            await generateSalesReport(date1, time1, date2, time2);
        // state (lastZDay, report) and show on presentation
        state = state.copyWith(
            data: Data(
                salesReport: salesReport,
                date1: date1,
                time1: time1,
                date2: date2,
                time2: time2));
      }

      state = state.copyWith(workable: Workable.ready);
    } catch (e) {
      state = state.copyWith(
          workable: Workable.failure, failure: Failure(errMsg: e.toString()));
    }
  }

  Future<String> generateSalesReport(
      String date1, String time1, String date2, String time2) async {
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

    final String zdaystr = currentDateTime('dd-MM-yyyy HH:mm');
    String ReportStr = '', ReportPrint = '';

    final List<List<String>> ReportArr =
        await reportRepository.getReportData(firstDate, lastDate);
    final List<List<String>> TransArr =
        await reportRepository.getTransReportData(firstDate, lastDate);
    final List<List<String>> TotMediaArr =
        await reportRepository.getTotalMediaReport(firstDate, lastDate);
    final List<List<String>> RefundArr =
        await reportRepository.refundSummary(firstDate, lastDate);
    final List<List<String>> VoidReport =
        await reportRepository.voidSummary(firstDate, lastDate);
    final List<List<String>> EstSalesReport =
        await reportRepository.getTotalSales(firstDate, lastDate);

    if (ReportArr.isNotEmpty) {
      iSalesQty = ReportArr[0][0].toDouble();
      iSalesAmt = ReportArr[0][1].toDouble();
      iDiscQty = ReportArr[0][2].toDouble();
      iDiscAmt = ReportArr[0][3].toDouble();
      billDiscQty = ReportArr[0][4].toDouble();
      billDiscAmt = ReportArr[0][5].toDouble();
      iFOCQty = ReportArr[0][6].toDouble();
      iFOCAmt = ReportArr[0][7].toDouble();
      BFOCQty = ReportArr[0][8].toDouble();
      BFOCAmt = ReportArr[0][9].toDouble();
      Tax0 = ReportArr[0][12].toDouble();
      Tax1 = ReportArr[0][13].toDouble();
      Tax2 = ReportArr[0][14].toDouble();
      Tax3 = ReportArr[0][15].toDouble();
      Tax4 = ReportArr[0][16].toDouble();
      Tax5 = ReportArr[0][17].toDouble();
      Tax6 = ReportArr[0][18].toDouble();
      Tax7 = ReportArr[0][19].toDouble();
      Tax8 = ReportArr[0][20].toDouble();
      Tax9 = ReportArr[0][21].toDouble();
      TotalTax =
          Tax0 + Tax1 + Tax2 + Tax3 + Tax4 + Tax5 + Tax6 + Tax7 + Tax8 + Tax9;
      TBill = ReportArr[0][22].toInt();
      TCover = ReportArr[0][23].toInt();
    }

    ReportStr += '${POSDtls.ScreenHeader1}\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}${POSDtls.ScreenHeader1}\n";

    ReportStr += '${POSDtls.ScreenHeader2}\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}${POSDtls.ScreenHeader2}\n";

    ReportStr += 'XZ Sales Report\n\n';
    ReportPrint += "${textPrintFormat("N", "L", "1")}XZ Sales Report\n";
    ReportPrint += "${textPrintFormat("N", "L", "1")}\n";

    ReportStr += '${addDash(40)}\n';
    ReportPrint += "${textPrintFormat("N", "L", "1")}${addDash(40)}\n";

    ReportStr += 'Type                  Qty        Amount\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}Type                  Qty        Amount\n";

    ReportStr += '${addDash(40)}\n';
    ReportPrint += "${textPrintFormat("N", "L", "1")}${addDash(40)}\n";

    final String strISQty =
        addSpace(iSalesQty.toString(), 5 - iSalesQty.toString().length);
    String strISAmt = iSalesAmt.toString();

    if (iSalesAmt < 0) {
      strISAmt = strISAmt.substring(1);
      strISAmt = '( $strISAmt)';
    }

    strISAmt = addSpace(strISAmt, 14 - strISAmt.length);
    ReportStr += 'Item Sales      (+) $strISQty $strISAmt\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}Item Sales      (+) $strISQty $strISAmt\n";

    final String strIDQty =
        addSpace(iDiscQty.toString(), 5 - iDiscQty.toString().length);
    String strIDAmt = iDiscAmt.toString();

    if (iDiscAmt < 0) {
      strIDAmt = strIDAmt.substring(1);
      strIDAmt = '( $strIDAmt)';
    }

    strIDAmt = addSpace(strIDAmt, 14 - strIDAmt.length);
    ReportStr += 'Item Discount   (-) $strIDQty $strIDAmt\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}Item Discount   (-) $strIDQty $strIDAmt\n";

    final String strBDQty =
        addSpace(billDiscQty.toString(), 5 - billDiscQty.toString().length);
    String strBDAmt = billDiscAmt.toString();

    if (billDiscAmt < 0) {
      strBDAmt = strBDAmt.substring(1);
      strBDAmt = '( $strBDAmt)';
    }

    strBDAmt = addSpace(strBDAmt, 14 - strBDAmt.length);
    ReportStr += 'Bill Discount   (-) $strBDQty $strBDAmt\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}Bill Discount   (-) $strBDQty $strBDAmt\n";

    final String strIFOCQty =
        addSpace(iFOCQty.toString(), 5 - iFOCQty.toString().length);
    String strIFOCAmt = iFOCAmt.toString();

    if (iFOCAmt < 0) {
      strIFOCAmt = strIFOCAmt.substring(1);
      strIFOCAmt = '( $strIFOCAmt)';
    }

    strIFOCAmt = addSpace(strIFOCAmt, 14 - strIFOCAmt.length);
    ReportStr += 'FOC Items       (-) $strIFOCQty $strIFOCAmt\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}FOC Items       (-) $strIFOCQty $strIFOCAmt\n";

    final String strBFOCQty =
        addSpace(BFOCQty.toString(), 5 - BFOCQty.toString().length);
    String strBFOCAmt = BFOCAmt.toString();

    if (BFOCAmt < 0) {
      strBFOCAmt = strBFOCAmt.substring(1);
      strBFOCAmt = '( $strBFOCAmt)';
    }

    strBFOCAmt = addSpace(strBFOCAmt, 14 - strBFOCAmt.length);
    ReportStr += 'FOC Bill        (-) $strBFOCQty $strBFOCAmt\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}FOC Bill        (-) $strBFOCQty $strBFOCAmt\n";

    final double TotalSales =
        iSalesAmt - iDiscAmt - billDiscAmt - iFOCAmt - BFOCAmt;

    if (EstSalesReport.isNotEmpty) {
      EstSales = EstSalesReport[0][0].toDouble();
    }

    if (TotalSales > 0) {
      String strTotalSales = TotalSales.toString();
      strTotalSales = addSpace(strTotalSales, 19 - strTotalSales.length);

      ReportStr += '\nTotal Sales     (=)  $strTotalSales\n';
      ReportPrint += "${textPrintFormat("N", "L", "1")}\n";
      ReportPrint +=
          "${textPrintFormat("N", "L", "1")}Total Sales     (=)  $strTotalSales\n";

      strTotalSales = EstSales.toString();
      strTotalSales = addSpace(strTotalSales, 19 - strTotalSales.length);

      ReportStr += 'Estimated Sales      $strTotalSales\n';
      ReportPrint +=
          "${textPrintFormat("N", "L", "1")}Estimated Sales      $strTotalSales\n";
    }

    ReportStr += '-----------------MEDIA------------------\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}-----------------MEDIA------------------\n";

    for (int i = 0; i < TransArr.length; i++) {
      final String Title = TransArr[i][0];
      String strQty = TransArr[i][1];
      strQty = addSpace(strQty, 24 - Title.length - strQty.length);

      final double TransAmt = TransArr[i][2].toDouble();
      String strAmt = TransAmt.toString();

      if (TransAmt < 0) {
        strAmt = strAmt.substring(1);
        strAmt = '( $strAmt)';
      }

      strAmt = addSpace(strAmt, 14 - strAmt.length);

      ReportStr += '$Title $strQty $strAmt\n';
      ReportPrint +=
          "${textPrintFormat("N", "L", "1")}$Title $strQty $strAmt\n";
    }

    ReportStr += '\n';
    ReportPrint += "${textPrintFormat("N", "L", "1")}\n";

    double TotQty = 0, TotCollection = 0;
    for (int i = 0; i < TotMediaArr.length; i++) {
      final String Title = TotMediaArr[i][0];
      final double TotMediaQty = TotMediaArr[i][1].toDouble();
      String strQty = TotMediaQty.toString();
      strQty = addSpace(strQty, 18 - Title.length - strQty.length);

      final double TotMediaAmt = TotMediaArr[i][2].toDouble();
      String strAmt = TotMediaAmt.toString();

      if (TotMediaAmt < 0) {
        strAmt = strAmt.substring(1);
        strAmt = '( $strAmt)';
      }

      strAmt = addSpace(strAmt, 14 - strAmt.length);

      ReportStr += '$Title $strQty $strAmt\n';
      ReportPrint +=
          "${textPrintFormat("N", "L", "1")}$Title $strQty $strAmt\n";

      TotQty += TotMediaQty;
      TotCollection += TotMediaAmt;
    }

    ReportStr += '----------VOID / REFUND SUMMARY---------\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}----------VOID / REFUND SUMMARY---------\n";
    double RefundQty = 0, RefundAmt = 0;
    if (RefundArr.isNotEmpty) {
      RefundQty = RefundArr[0][0].toDouble();
      RefundAmt = RefundArr[0][1].toDouble();
    }

    String strRQty = RefundQty.toString();
    strRQty = addSpace(strRQty, 18 - strRQty.length);

    String strRAmt = RefundAmt.toString();
    strRAmt = addSpace(strRAmt, 14 - strRAmt.length);

    ReportStr += 'Refund $strRQty $strRAmt\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}Refund $strRQty $strRAmt\n";

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

    ReportStr += 'Pre-Send Void $strPrVQty $strPrVAmt\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}Pre-Send Void $strPrVQty $strPrVAmt\n";

    String strPoVQty = PreVoidQty.toString();
    strPoVQty = addSpace(strPoVQty, 10 - strPoVQty.length);

    String strPoVAmt = PreVoidAmt.toString();
    strPoVAmt = addSpace(strPoVAmt, 14 - strPoVAmt.length);

    ReportStr += 'Post-Send Void $strPoVQty $strPoVAmt\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}Post-Send Void $strPoVQty $strPoVAmt\n";

    ReportStr += '${addDash(40)}\n';
    ReportPrint += "${textPrintFormat("N", "L", "1")}${addDash(40)}\n";

    String strTotQty = TotQty.toString();
    strTotQty = addSpace(strTotQty, 8 - strTotQty.length);

    String strTotColl = TotCollection.toString();
    if (TotCollection < 0) {
      strTotColl = strTotColl.substring(1);
      strTotColl = '( $strTotColl)';
    }
    strTotColl = addSpace(strTotColl, 14 - strTotColl.length);

    ReportStr += 'Total Collection $strTotQty $strTotColl\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}Total Collection $strTotQty $strTotColl\n";

    if (TotalTax > 0) {
      ReportStr += '------------------TAX-------------------\n';
      ReportPrint +=
          "${textPrintFormat("N", "L", "1")}------------------TAX-------------------\n";

      if (Tax0 > 0) {
        final List<List<String>> TaxArray =
            await reportRepository.getTaxApplied('0');
        final String TaxName = TaxArray[0][1];
        String strTax = Tax0.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ReportStr += '$TaxName $strTax\n';
        ReportPrint += "${textPrintFormat("N", "L", "1")}$TaxName $strTax\n";
      }

      if (Tax1 > 0) {
        final List<List<String>> TaxArray =
            await reportRepository.getTaxApplied('1');
        final String TaxName = TaxArray[0][1];
        String strTax = Tax1.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ReportStr += '$TaxName $strTax\n';
        ReportPrint += "${textPrintFormat("N", "L", "1")}$TaxName $strTax\n";
      }

      if (Tax2 > 0) {
        final List<List<String>> TaxArray =
            await reportRepository.getTaxApplied('2');
        final String TaxName = TaxArray[0][1];
        String strTax = Tax2.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ReportStr += '$TaxName $strTax\n';
        ReportPrint += "${textPrintFormat("N", "L", "1")}$TaxName $strTax\n";
      }

      if (Tax3 > 0) {
        final List<List<String>> TaxArray =
            await reportRepository.getTaxApplied('3');
        final String TaxName = TaxArray[0][1];
        String strTax = Tax3.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ReportStr += '$TaxName $strTax\n';
        ReportPrint += "${textPrintFormat("N", "L", "1")}$TaxName $strTax\n";
      }

      if (Tax4 > 0) {
        final List<List<String>> TaxArray =
            await reportRepository.getTaxApplied('4');
        final String TaxName = TaxArray[0][1];
        String strTax = Tax4.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ReportStr += '$TaxName $strTax\n';
        ReportPrint += "${textPrintFormat("N", "L", "1")}$TaxName $strTax\n";
      }

      if (Tax5 > 0) {
        final List<List<String>> TaxArray =
            await reportRepository.getTaxApplied('5');
        final String TaxName = TaxArray[0][1];
        String strTax = Tax5.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ReportStr += '$TaxName $strTax\n';
        ReportPrint += "${textPrintFormat("N", "L", "1")}$TaxName $strTax\n";
      }

      if (Tax6 > 0) {
        final List<List<String>> TaxArray =
            await reportRepository.getTaxApplied('6');
        final String TaxName = TaxArray[0][1];
        String strTax = Tax6.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ReportStr += '$TaxName $strTax\n';
        ReportPrint += "${textPrintFormat("N", "L", "1")}$TaxName $strTax\n";
      }

      if (Tax7 > 0) {
        final List<List<String>> TaxArray =
            await reportRepository.getTaxApplied('7');
        final String TaxName = TaxArray[0][1];
        String strTax = Tax7.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ReportStr += '$TaxName $strTax\n';
        ReportPrint += "${textPrintFormat("N", "L", "1")}$TaxName $strTax\n";
      }

      if (Tax8 > 0) {
        final List<List<String>> TaxArray =
            await reportRepository.getTaxApplied('8');
        final String TaxName = TaxArray[0][1];
        String strTax = Tax8.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ReportStr += '$TaxName $strTax\n';
        ReportPrint += "${textPrintFormat("N", "L", "1")}$TaxName $strTax\n";
      }

      if (Tax9 > 0) {
        final List<List<String>> TaxArray =
            await reportRepository.getTaxApplied('9');
        final String TaxName = TaxArray[0][1];
        String strTax = Tax9.toString();
        strTax = addSpace(strTax, 39 - TaxName.length - strTax.length);

        ReportStr += '$TaxName $strTax\n';
        ReportPrint += "${textPrintFormat("N", "L", "1")}$TaxName $strTax\n";
      }
    }

    ReportStr += '${addDash(40)}\n';
    ReportPrint += "${textPrintFormat("N", "L", "1")}${addDash(40)}\n";

    String strNetSales = TotalSales.toString();
    if (TotalSales < 0) {
      strNetSales = strNetSales.substring(1);
      strNetSales = '( $strNetSales)';
    }

    strNetSales = addSpace(strNetSales, 29 - strNetSales.length);

    ReportStr += 'Nett Sales $strNetSales\n';
    ReportPrint += "${textPrintFormat("N", "L", "1")}Nett Sales $strNetSales\n";

    ReportStr += '${addDash(40)}\n';
    ReportPrint += "${textPrintFormat("N", "L", "1")}${addDash(40)}\n";

    final String strTBill =
        addSpace(TBill.toString(), 23 - TBill.toString().length);
    ReportStr += 'Total # of Bills $strTBill\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}Total # of Bills $strTBill\n";

    final String strTCover =
        addSpace(TCover.toString(), 23 - TCover.toString().length);
    ReportStr += 'Total # of Bills $strTCover\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}Total # of Bills $strTCover\n";

    ReportStr += '${addDash(40)}\n';
    ReportStr += '${addDash(40)}\n\n';
    ReportPrint += "${textPrintFormat("N", "L", "1")}${addDash(40)}\n";
    ReportPrint += "${textPrintFormat("N", "L", "1")}${addDash(40)}\n";
    ReportPrint += "${textPrintFormat("N", "L", "1")}\n";

    final List<List<String>> RcptNoArr =
        await reportRepository.getReceiptNo(firstDate, lastDate);
    if (RcptNoArr.isNotEmpty) {
      String RcptBegin = RcptNoArr[0][0];
      RcptBegin = addSpace(RcptBegin, 25 - RcptBegin.length);
      String RcptEnd = RcptNoArr[0][1];
      RcptEnd = addSpace(RcptEnd, 27 - RcptEnd.length);

      ReportStr += 'Begin Receipt# $RcptBegin\n';
      ReportStr += 'End Receipt# $RcptEnd\n\n\n';

      ReportPrint +=
          "${textPrintFormat("N", "L", "1")}Begin Receipt# $RcptBegin\n";
      ReportPrint += "${textPrintFormat("N", "L", "1")}End Receipt# $RcptEnd\n";
      ReportPrint += "${textPrintFormat("N", "L", "1")}\n";
      ReportPrint += "${textPrintFormat("N", "L", "1")}\n";
    } else {
      String RcptBegin = 'A00000000000';
      RcptBegin = addSpace(RcptBegin, 25 - RcptBegin.length);
      String RcptEnd = 'A00000000000';
      RcptEnd = addSpace(RcptEnd, 27 - RcptEnd.length);

      ReportStr += 'Begin Receipt# $RcptBegin\n';
      ReportStr += 'End Receipt# $RcptEnd\n\n\n';

      ReportPrint +=
          "${textPrintFormat("N", "L", "1")}Begin Receipt# $RcptBegin\n";
      ReportPrint += "${textPrintFormat("N", "L", "1")}End Receipt# $RcptEnd\n";
      ReportPrint += "${textPrintFormat("N", "L", "1")}\n";
      ReportPrint += "${textPrintFormat("N", "L", "1")}\n";
    }

    ReportStr += '========================================\n';
    ReportPrint +=
        "${textPrintFormat("N", "L", "1")}========================================\n";

    final String FDateStr = '$date1 $time1';
    final String LDateStr = '$date2 $time2';

    ReportStr += '$FDateStr-$LDateStr\n\n';
    ReportPrint +=
        "${"${textPrintFormat("N", "L", "1")}$FDateStr-$LDateStr"}\n";
    ReportPrint += "${textPrintFormat("N", "L", "1")}\n";
    return ReportStr;
  }

  // Print Report
  Future<void> printReport() async {
    await printController.doPrint(4, 0, reportPrint);
  }

  // Refresh Report, dd/MM/yyyy, HH:mm:ss
  Future<void> refreshReport(String startDate, String startTime, String endDate,
      String endTime) async {
    try {
      firstDate =
          '${convertFormat(startDate, 'yyyy-MM-dd')} ${convertFormat(startTime, 'HH:mm:ss')}';
      lastDate =
          '${convertFormat(endDate, 'yyyy-MM-dd')} ${convertFormat(endTime, 'HH:mm:ss')}';

      final DateTime checkFDate = DateTime.parse(firstDate);
      final DateTime checkLDate = DateTime.parse(lastDate);

      if (checkFDate.compareTo(checkLDate) > 0) {
        state = state.copyWith(
            failure: Failure(
                errMsg:
                    'XZ Report Failed! End Date should be greater than Start Date'));
      } else {
        await generateSalesReport(startDate, startTime, endDate, endTime);
      }
    } catch (e) {
      state = state.copyWith(failure: Failure(errMsg: e.toString()));
    }
  }
}
