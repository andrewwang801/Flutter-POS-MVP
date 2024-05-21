import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:raptorpos/common/GlobalConfig.dart';

import 'package:raptorpos/common/constants/strings.dart';
import 'package:raptorpos/common/services/printer_manager.dart';
import 'package:raptorpos/common/utils/datetime_util.dart';
import 'package:raptorpos/common/utils/strings_util.dart';
import 'package:raptorpos/common/utils/type_util.dart';
import 'package:raptorpos/payment/repository/i_payment_repository.dart';
import 'package:raptorpos/print/repository/i_print_repository.dart';
import '../../common/extension/string_extension.dart';
import 'print_state.dart';

@Injectable()
class PrintController extends StateNotifier<PrintState>
    with StringUtil, TypeUtil, DateTimeUtil {
  PrintController(
      this.printRepository, this.paymentRepository, this.printerManager)
      : super(PrintLoadingState());

  final IPaymentRepository paymentRepository;
  final IPrintRepository printRepository;
  final PrinterManager printerManager;

  List<String> printArr = <String>[];

  Future<void> kpPrinting(int kpsNo, int kpsPlNo, String kpTblNo,
      String tblName, String kpTblName, int transID, int countReprint) async {
    String tempCtgName = '', tempIName = '', kitchenPrint = '';
    int kpNo = 0, tempCtgID = 0;
    bool blnIndividual;
    double tempQty = 0;

    final List<List<String>> kpscArray = await printRepository
        .getKPSalesCategory(kpsNo, kpsPlNo, tblName, kpTblName, transID);
    for (List<String> kpsc in kpscArray) {
      tempCtgName = kpsc[0];
      tempCtgID = kpsc[1].toInt();

      final List<List<String>> kpArray = await printRepository.getKPNo(
          kpsNo, kpsPlNo, tempCtgName, tblName, kpTblName, transID);
      for (List<String> kp in kpArray) {
        kpNo = kp[0].toInt();
        if (POSDtls.blnKPPartialConsolidate) {
          kitchenPrint = await printRepository.generateKP(
              kpsNo,
              kpsPlNo,
              kpTblNo,
              tempCtgName,
              kpNo,
              tblName,
              kpTblName,
              transID,
              countReprint);
          printArr.add(kitchenPrint);
        } else {
          final List<List<String>> indvItems =
              await printRepository.getKPIndividualItems(kpsNo, kpsPlNo, kpNo,
                  kpTblNo, tempCtgName, tblName, kpTblName, transID);
          for (List<String> indvItem in indvItems) {
            tempIName = indvItem[1];
            tempQty = indvItem[3].toDouble();
            blnIndividual = indvItem[7].toBool();

            kitchenPrint = await printRepository.generateIndividualKP(
                kpsNo,
                kpsPlNo,
                kpTblNo,
                tempCtgName,
                kpNo,
                tempIName,
                tempQty,
                blnIndividual,
                tblName,
                kpTblName,
                transID,
                countReprint);
            printArr.add(kitchenPrint);
          }

          kitchenPrint = await printRepository.generateKPIndividual(
              kpsNo,
              kpsPlNo,
              kpTblNo,
              tempCtgName,
              kpNo,
              tblName,
              kpTblName,
              transID,
              countReprint);
          if (kitchenPrint.isNotEmpty) {
            printArr.add(kitchenPrint);
          }
        }
      }
    }
  }

  Future<void> masterKPPrint(int mKpsNo, int mKpSplNo, String mKpTblNo,
      String tblName, String kpTblName, int transID, int countReprint) async {
    final List<List<String>> data =
        await printRepository.getMasterKPID(POSDtls.deviceNo);
    if (data.isNotEmpty) {
      for (int i = 0; i < 3; i++) {
        final int masterKPID = data[0][i].toInt();
        final List<List<String>> scArr = await printRepository.getMasterKPSC(
            mKpsNo, mKpSplNo, masterKPID, i + 1);
        for (int i = 0; i < scArr.length; i++) {
          final String ctgName = scArr[i][1];
          final int ctgId = scArr[i][0].toInt();
          final String strMasterKP = await printRepository.generateMasterKP(
              masterKPID, ctgName, ctgId, mKpTblNo, mKpsNo, mKpSplNo, i + 1);
          printArr.add(strMasterKP);
        }
      }
    }
  }

  // Future<void> doPrint(int status, int printSNo, String printData) async {
  //   try {
  //     if (printerManager.getPrinters().isEmpty) {
  //       state = PrintErrorState(errMsg: 'There is no printer connected');
  //     } else {
  //       if (status == 1) {
  //         await printerManager.print(printData);
  //       } else if (status == 2) {
  //         await printerManager.print(printData);
  //       } else if (status == 3) {
  //         final String printText = await getBill(printSNo, printData);
  //         await printerManager.print(printText);
  //       } else if (status == 4) {
  //         await printerManager.print(printData);
  //       } else if (status == 5) {
  //         final String printText = await getOpenBill(printSNo);
  //         await printerManager.print(printData);
  //       }
  //       state = PrintSuccessState();
  //     }
  //   } catch (e) {
  //     state = PrintErrorState(errMsg: e.toString());
  //   }
  // }

  Future<void> doPrint(int status, int printSNo, String printData) async {
    try {
      if (printerManager.getPrinters().isEmpty) {
        throw Exception(message_no_printer);
      } else {
        if (status == 1) {
          await printerManager.print(printData);
        } else if (status == 2) {
          await printerManager.print(printData);
        } else if (status == 3) {
          final String printText = await getBill(printSNo, printData);
          await printerManager.print(printText);
        } else if (status == 4) {
          await printerManager.print(printData);
        } else if (status == 5) {
          final String printText = await getOpenBill(printSNo);
          await printerManager.print(printText);
        }
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> printBill(int printSNo, String status) async {
    try {
      if (status == PrintStatus.k_close_tables) {
        await doPrint(3, printSNo, PrintStatus.k_close);
      } else if (status == PrintStatus.k_refund) {
        await doPrint(3, printSNo, PrintStatus.k_refund);
      } else if (status == PrintStatus.k_void_table) {
        await doPrint(3, printSNo, PrintStatus.k_all_void);
      } else {
        await doPrint(3, printSNo, '');
      }
      state = PrintSuccessState();
    } catch (e) {
      state = PrintErrorState(errMsg: e.toString());
    }
  }

  Future<void> kpPrint() async {
    try {
      final List<List<String>> kpscArray =
          await printRepository.getKPSalesCategory(
              GlobalConfig.salesNo,
              GlobalConfig.splitNo,
              TableName.table_held_items,
              TableName.table_kp_status,
              0);
      if (kpscArray.isNotEmpty) {
        await kpPrinting(
            GlobalConfig.salesNo,
            GlobalConfig.splitNo,
            GlobalConfig.tableNo,
            TableName.table_held_items,
            TableName.table_kp_status,
            0,
            0);

        if (POSDtls.blnKPPrintMaster) {
          await masterKPPrint(
              GlobalConfig.salesNo,
              GlobalConfig.splitNo,
              GlobalConfig.tableNo,
              TableName.table_held_items,
              TableName.table_kp_status,
              0,
              0);
        }

        if (printerManager.getPrinters().isEmpty) {
          printArr.clear();
          state = PrintErrorState(errMsg: message_no_printer);
        } else {
          for (String printData in printArr) {
            // Print Action
            // await doPrint(2, 0, printData);
            await printerManager.print(printData);
          }
          printArr.clear();
          await printRepository.updateKPPrintItem(
              GlobalConfig.salesNo, GlobalConfig.splitNo);
          state = PrintSuccessState();
        }
      }
    } catch (e) {
      state = PrintErrorState(errMsg: e.toString());
    }
  }

  Future<String> getBill(int printSNo, String printStatus) async {
    List<List<String>> refundArray = <List<String>>[];

    if (printStatus == PrintStatus.k_refund) {
      refundArray = await paymentRepository.getPrintRefund(printSNo);
      printSNo = refundArray[0][4].toInt();
    }

    final List<List<String>> scArray =
        await paymentRepository.getPrintCategory(printSNo);
    final List<List<String>> discArray =
        await paymentRepository.getPrintBillDisc(printSNo);
    final List<List<String>> priceArray =
        await paymentRepository.getPrintTotal(printSNo);
    final List<List<String>> countArray =
        await paymentRepository.getTotalItemQty(printSNo);
    final List<List<String>> paymentArray =
        await paymentRepository.getPrintPayment(printSNo);
    final List<List<String>> promoArray =
        await paymentRepository.getPrintPromo(printSNo);

    final String tblNo = priceArray[0][4];
    double taxTotal = 0;

    final DateFormat format = DateFormat('dd/MM/yyyy HH:mm');
    final String dateStr = format.format(DateTime.now());
    final int coverPrint = priceArray[0][2].toInt();
    final String rcptNoPrint = priceArray[0][3];
    String tempText = '';

    tempText += '${textPrintFormat('N', 'C', '1')}${POSDtls.ScreenHeader1}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}${POSDtls.ScreenHeader2}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}${POSDtls.ScreenHeader3}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}$tblNo\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    final String pax = 'Pax: $coverPrint';
    final String oprtName = 'OP: ${GlobalConfig.operatorName}';
    final String temp = addSpace(oprtName, 38 - pax.length - oprtName.length);
    tempText += '${textPrintFormat('N', 'C', '1')}$pax$temp\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    final String posTitle = 'POS Title: ${POSDtls.strPOSTitle}';
    tempText += '${textPrintFormat('N', 'C', '1')}$posTitle\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    final String rcptStr = 'Rcpt#: $rcptNoPrint';
    final String datePrint =
        addSpace(dateStr, 38 - rcptStr.length - dateStr.length);
    tempText += '${textPrintFormat('N', 'C', '1')}$rcptStr$datePrint\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    tempText += '${textPrintFormat('N', 'C', '1')}${addDash(38)}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    double sTotal = priceArray[0][0].toDouble();
    final double itemTotal = sTotal;

    for (int i = 0; i < scArray.length; i++) {
      final String ctgName = scArray[i][0];
      final List<List<String>> itemArray =
          await paymentRepository.getPrintItem(printSNo, ctgName);

      final String dash = addDash((36 - ctgName.length) ~/ 2);
      tempText += '${textPrintFormat('N', 'C', '1')}$dash$ctgName$dash\n';

      for (int j = 0; j < itemArray.length; j++) {
        String discType = itemArray[j][4];
        String promoType = itemArray[j][6];
        final double disc = itemArray[j][5].toDouble();
        final double promo = itemArray[j][7].toDouble();
        final int qty = itemArray[j][0].toInt();
        final String tempIName = itemArray[j][1];
        final bool prep = itemArray[j][3].toBool();
        final double iAmount = itemArray[j][2].toDouble();

        String iName = '', iName2 = '', tempIName2 = '';

        if (!POSDtls.printZeroPrice) {
          if (iAmount == 0) {
            continue;
          }
        }

        if (prep && !POSDtls.PrintPrepWithPrice) {
          if (iAmount == 0) {
            continue;
          }
        }

        if (tempIName.length > 20) {
          tempIName2 = tempIName.substring(20);
          iName = tempIName.substring(0, 20);
          iName2 = addSpace(tempIName2, 4);
        }

        String strIAmount = iAmount.toInt().toString();
        String strQty = qty.toString();
        if (qty != 0 && !prep) {
          strQty = addSpace(strQty, 3 - strQty.length);
          iName = addSpace(tempIName, 1);
          strIAmount =
              addSpace(strIAmount, 35 - iName.length - strIAmount.length);
        } else if (prep) {
          if (POSDtls.PrintPrepWithPrice) {
            strQty = addSpace(strQty, 3 - strQty.length);
            iName = addSpace(tempIName, 1);
            strIAmount =
                addSpace(strIAmount, 29 - iName.length - strIAmount.length);
            tempText += '     *';
          }
        } else {
          strQty = '0';
          strQty = addSpace(strQty, 3 - strQty.length);
          iName = addSpace(tempIName, 4);
          strIAmount =
              addSpace(strIAmount, 37 - iName.length - strIAmount.length);
        }

        tempText +=
            '${textPrintFormat('N', 'C', '1')} $strQty $iName $strIAmount\n';
        if (tempIName2.isNotEmpty) {
          tempText += '${textPrintFormat('N', 'C', '1')} $iName2\n';
        }

        if (discType.isNotEmpty && discType != 'FOC Item') {
          discType = addSpace(discType, 4);
          String strDisc = disc.toString();
          strDisc = '($strDisc)';
          strDisc = addSpace(strDisc, 37 - discType.length - strDisc.length);

          tempText += '${textPrintFormat('N', 'C', '1')}$discType $strDisc\n';
          sTotal -= disc;
        }

        if (promo != 0) {
          if (POSDtls.PrintPrmnDtls) {
            promoType = addSpace(promoType, 4);
            String strPromo = promo.toString();
            strPromo = '($strPromo)';
            strPromo =
                addSpace(strPromo, 38 - promoType.length - strPromo.length);
            tempText +=
                '${textPrintFormat('N', 'C', '1')}$promoType$strPromo\n';
          }
          sTotal -= promo;
        }
      }
    }
    if (printStatus == PrintStatus.k_all_void) {
      tempText += '${textPrintFormat('N', 'C', '1')}${addDash(38)}\n';
      tempText +=
          '${textPrintFormat('N', 'C', '1')} ********* ALL VOID *********n';
      tempText += '${textPrintFormat('N', 'C', '1')}\n';
    } else {
      if (promoArray.isNotEmpty) {
        final String title = addSpace('ITEMS TOTAL', 4);
        String strItemTotal = itemTotal.toString();
        strItemTotal =
            addSpace(strItemTotal, 37 - title.length - strItemTotal.length);

        tempText += '${textPrintFormat('N', 'C', '1')}${addDash(38)}\n';
        tempText += '${textPrintFormat('N', 'C', '1')} $title $strItemTotal\n';
        for (int i = 0; i < promoArray.length; i++) {
          String pName = promoArray[i][0];
          final double pValue = promoArray[i][1].toDouble();
          String strPValue = pValue.toString();

          strPValue = '( $strPValue )';
          pName = addSpace(pName, 4);
          strPValue = addSpace(strPValue, 37 - pName.length - strPValue.length);

          tempText += '${textPrintFormat('N', 'C', '1')} $pName$strPValue\n';
        }
      }
      tempText += '${textPrintFormat('N', 'C', '1')}${addDash(38)}\n';
      if (sTotal > 0) {
        String strSTotal = sTotal.toString();
        strSTotal = addSpace(strSTotal, 24 - strSTotal.length);

        tempText +=
            '${textPrintFormat('N', 'C', '1')}       SUBTOTAL $strSTotal\n';
      }
      if (discArray.isNotEmpty) {
        final String dbName = discArray[0][0];
        final double dbValue = discArray[0][1].toDouble();
        sTotal -= dbValue;

        String strDBValue = dbValue.toString();
        strDBValue = '( $strDBValue )';
        strDBValue =
            addSpace(strDBValue, 32 - dbName.length - strDBValue.length);
        tempText +=
            '${textPrintFormat('N', 'C', '1')}      $dbName$strDBValue\n';
      }

      tempText += '${textPrintFormat('N', 'C', '1')} ${addDash(38)}\n';
      if (sTotal > 0) {
        String strSTotal = sTotal.toString();
        strSTotal = addSpace(strSTotal, 24 - strSTotal.length);

        tempText +=
            '${textPrintFormat('N', 'C', '1')}       SUBTOTAL $strSTotal\n';

        final List<List<String>> taxArray =
            await paymentRepository.getPrintTax(printSNo);
        final List<Map<String, dynamic>> tTitleArray =
            await paymentRepository.getTaxRateData();

        if (POSDtls.PrintTax) {
          for (int i = 0; i < tTitleArray.length; i++) {
            final int taxCode = dynamicToInt(tTitleArray[i]['TaxCode']);
            String taxName = tTitleArray[i]['Title'].toString();
            final double taxValue = taxArray[0][taxCode].toDouble();
            if (taxValue > 0) {
              taxName = addSpace(taxName, 5);
              String strTaxValue = taxValue.toString();
              strTaxValue = addSpace(
                  strTaxValue, 37 - taxName.length - strTaxValue.length);

              tempText +=
                  '${textPrintFormat('N', 'C', '1')}$taxName$strTaxValue\n';
            }
            taxTotal += taxValue;
          }
        }

        if (POSDtls.PrintTotalTax) {
          final String title = addSpace(POSDtls.TotalTaxTitle, 5);
          String strTaxTotal = taxTotal.toString();
          strTaxTotal =
              addSpace(strTaxTotal, 37 - title.length - strTaxTotal.length);

          tempText += '${textPrintFormat('N', 'C', '1')} ${addDash(38)}\n';
        }
      } else {
        String strSTotal = sTotal.toString();
        strSTotal = addSpace(strSTotal, 24 - strSTotal.length);
        tempText +=
            '${textPrintFormat('N', 'C', '1')}     SUBTOTAL $strSTotal\n';
      }
      if (taxTotal == 0) {
        String strSTotal = sTotal.toString();
        strSTotal = addSpace(strSTotal, 27 - strSTotal.length);
        tempText +=
            '${textPrintFormat('N', 'L', '1')}       TOTAL $strSTotal\n';
      } else {
        final double gTotal = priceArray[0][1].toDouble();
        String strGTotal = sTotal.toString();
        strGTotal = addSpace(strGTotal, 27 - strGTotal.length);
        tempText +=
            '${textPrintFormat('N', 'C', '1')}       TOTAL $strGTotal\n';
      }

      String totalItem = 'Total Item : ${countArray[0][0]}';
      totalItem = addSpace(totalItem, 5);

      String totalQty = 'Total Qty : ${countArray[0][1]}';
      totalQty = addSpace(totalQty, 38 - totalItem.length - totalQty.length);
      tempText += '${textPrintFormat('N', 'C', '1')} $totalItem$totalQty\n';

      for (int i = 0; i < paymentArray.length; i++) {
        final String payName = paymentArray[i][0];
        final double payAmt = paymentArray[i][1].toDouble();
        String strPayAmt = payAmt.toString();
        strPayAmt = addSpace(strPayAmt, 37 - payName.length - strPayAmt.length);
        tempText += '${textPrintFormat('N', 'C', '1')} $payName$strPayAmt\n';
      }

      if (printStatus == 'Refund') {
        final String rcptRfnd = refundArray[0][0];
        tempText +=
            '${textPrintFormat('N', 'C', '1')} ********* REFUND BILL *********\n';
        tempText +=
            '${textPrintFormat('N', 'C', '1')} RFND of Rcpt#$rcptRfnd\n';
      } else if (printStatus == 'Close') {
        final double changeAmt =
            paymentArray[paymentArray.length - 1][2].toDouble();
        final String strChangeAmt = changeAmt.toString();
        tempText += '${textPrintFormat('N', 'C', '1')} Change $strChangeAmt\n';
        tempText += '${textPrintFormat('N', 'C', '1')}\n';
      }
    }
    tempText += '${textPrintFormat('N', 'C', '1')} ${addDash(38)}\n';
    tempText += '${textPrintFormat('N', 'C', '1')} Closed Bill\n';
    tempText += '${textPrintFormat('N', 'C', '1')} ${addDash(38)}\n';
    return tempText;
  }

  Future<String> getBillForPreview(int salesNo, int splitNo, int cover,
      String tableNo, String rcptNo) async {
    String preview = '';
    final List<List<String>> scArray =
        await paymentRepository.getSalesCatData(salesNo);
    final List<double> priceArray = await paymentRepository.getAmountOrder(
        salesNo, splitNo, tableNo.toInt(), POSDefault.TaxInclusive);
    final List<List<String>> paymentArray =
        await paymentRepository.getPaymentData(salesNo);
    final List<String> totalItemArray =
        await paymentRepository.getTotalItem(salesNo);

    final String date = currentDateTime('dd/MM/yyyy HH:mm');

    preview +=
        '${addSpace(POSDtls.ScreenHeader1, (20 - POSDtls.ScreenHeader1.length) ~/ 2)}\n';
    preview +=
        '${addSpace(POSDtls.ScreenHeader2, (20 - POSDtls.ScreenHeader2.length) ~/ 2)}\n';
    preview +=
        '${addSpace(POSDtls.ScreenHeader3, (20 - POSDtls.ScreenHeader3.length) ~/ 2)}\n\n\n';

    final String tbl = 'TABLE : $tableNo';
    preview += '${addSpace(tbl, (20 - tbl.length) ~/ 2)}\n';

    final String pax = 'Pax: $cover';
    final String OpName = 'OP:${GlobalConfig.operatorName}';
    preview += '$pax${addSpace(OpName, 40 - pax.length - OpName.length)}\n';
    preview += 'POSTitle:${POSDtls.strPOSTitle}\n';

    final String rcpt = 'Rcpt#:$rcptNo';
    final String dateprint = addSpace(date, 40 - rcpt.length - date.length);
    preview += '$rcpt$dateprint\n';

    preview += "${addChar("-", 40)}\n";

    double sTotal = priceArray[2];
    final double itemTotal = sTotal;

    for (int i = 0; i < scArray.length; i++) {
      final String ctgName = scArray[i][0];
      final List<List<String>> itemArray =
          await paymentRepository.getItemData(salesNo, ctgName);

      final String dash = addChar('-', (38 - ctgName.length) ~/ 2);
      preview += '$dash $ctgName $dash-\n';

      for (int j = 0; j < itemArray.length; j++) {
        final double qty = itemArray[j][0].toDouble();
        final String tempIName = itemArray[j][1];
        final double itemAmount = itemArray[j][2].toDouble();
        final bool prep = itemArray[j][3].toBool();
        String discType = itemArray[j][4];
        final double discValue = itemArray[j][5].toDouble();
        String promoName = itemArray[j][6];
        final double promoValue = itemArray[j][7].toDouble();

        String iName = tempIName, iName2 = '', tempIName2 = '';

        if (!POSDtls.printZeroPrice) {
          if (itemAmount == 0) {
            continue;
          }
        }

        if (prep && !POSDtls.PrintPrepWithPrice) {
          if (itemAmount == 0) {
            continue;
          }
        }

        if (tempIName.length > 20) {
          tempIName2 = tempIName.substring(20);
          iName = tempIName.substring(0, 20);
          iName2 = addSpace(tempIName2, 4);
        }

        String strIAmount = itemAmount.toString();
        String strQty = '';
        if (qty != 0 && !prep) {
          strQty = addSpace(qty.toString(), 3 - qty.toString().length);
          iName = addSpace(iName, 1);
          strIAmount =
              addSpace(strIAmount, 37 - iName.length - strIAmount.length);
        } else if (prep) {
          if (POSDtls.PrintPrepWithPrice) {
            preview += '     *';
            strQty = addSpace(qty.toString(), 3 - qty.toString().length);
            iName = addSpace(iName, 1);
            strIAmount =
                addSpace(strIAmount, 31 - iName.length - strIAmount.length);
          }
        } else {
          strQty = '0';
          strQty = addSpace(strQty, 3 - strQty.length);
          iName = addSpace(iName, 1);
          strIAmount =
              addSpace(strIAmount, 39 - iName.length - strIAmount.length);
        }

        preview += '$strQty $iName $strIAmount\n';
        if (tempIName2.isNotEmpty) {
          // preview += '$iName2\n';
        }

        if (discType.isNotEmpty && discType != 'FOC Item') {
          discType = addSpace(discType, 4);
          String strDisc = '( $discValue)';
          strDisc = addSpace(strDisc, 40 - discType.length - strDisc.length);

          preview += '$discType$strDisc\n';

          sTotal -= discValue;
        }

        if (promoValue != 0) {
          if (POSDtls.PrintPrmnDtls) {
            promoName = addSpace(promoName, 4);
            String strPromo = '( $promoValue)';
            strPromo =
                addSpace(strPromo, 40 - promoName.length - strPromo.length);

            preview += '$promoName$strPromo\n';
          }

          sTotal -= promoValue;
        }
      }
    }

    final List<List<String>> promoArray =
        await paymentRepository.getPromotionData(salesNo);
    if (promoArray.isNotEmpty) {
      String itemText = 'ITEMS TOTAL';
      itemText = addSpace(itemText, 4);
      String strTotal = itemTotal.toString();

      strTotal = addSpace(strTotal, 39 - itemText.length - strTotal.length);

      preview += "${addChar("-", 40)}\n";
      preview += ' $itemText$strTotal\n';

      for (int i = 0; i < promoArray.length; i++) {
        String pName = promoArray[i][0];
        final double pValue = promoArray[i][1].toDouble();
        String strPValue = pValue.toString();

        strPValue = '( $strPValue)';
        pName = addSpace(pName, 4);
        strPValue = addSpace(strPValue, 39 - pName.length - strPValue.length);

        preview += ' $pName$strPValue\n';
      }
    }

    preview += '${addChar('-', 40)}\n';
    if (sTotal > 0) {
      String strST = sTotal.toString();
      strST = addSpace(strST, 26 - strST.length);

      preview += '     SUBTOTAL $strST\n';
    }

    preview += '${addChar('-', 40)}\n';
    if (sTotal > 0) {
      String strSTotal = sTotal.toString();
      strSTotal = addSpace(strSTotal, 26 - strSTotal.length);
      preview += '     SUBTOTAL $strSTotal\n';

      final List<double> taxArray =
          await paymentRepository.findTax(salesNo, splitNo, tableNo, 2);
      final List<Map<String, dynamic>> tTitleArray =
          await paymentRepository.getTaxRateData();
      double taxTotal = 0;
      if (POSDtls.PrintTax) {
        for (int i = 0; i < tTitleArray.length; i++) {
          final int taxCode = dynamicToInt(tTitleArray[i]['TaxCode']);
          String taxName = tTitleArray[i]['Title'].toString();

          final double taxValue = taxArray[taxCode];
          if (taxValue > 0) {
            taxName = addSpace(taxName, 5);
            String strTaxValue = taxValue.toString();
            strTaxValue =
                addSpace(strTaxValue, 39 - taxName.length - strTaxValue.length);

            preview += '$taxName$strTaxValue\n';
          }
          taxTotal += taxValue;
        }
      }

      if (POSDtls.PrintTotalTax) {
        final String title = addSpace(POSDtls.TotalTaxTitle, 5);
        String strTaxTotal = taxTotal.toString();
        strTaxTotal =
            addSpace(strTaxTotal, 39 - title.length - strTaxTotal.length);

        preview += '$title$strTaxTotal\n';
      }

      preview += '${addChar('-', 40)}\n';
    } else {
      String strSTotal = sTotal.toString();
      strSTotal = addSpace(strSTotal, 26 - strSTotal.length);
      preview += '     SUBTOTAL $strSTotal\n';
    }

    final double gTotal = priceArray[0];
    String strGTotal = gTotal.toString();
    strGTotal = addSpace(strGTotal, 32 - strGTotal.length);

    preview += '  TOTAL $strGTotal\n';

    String strTotalItem = 'Total Item : ${totalItemArray[0]}';
    strTotalItem = addSpace(strTotalItem, 5);

    String strTotalQty = 'Total Qty : ${totalItemArray[1]}';
    strTotalQty =
        addSpace(strTotalQty, 40 - strTotalItem.length - strTotalQty.length);

    preview += '$strTotalItem$strTotalQty\n';

    if (paymentArray.isNotEmpty) {
      double paidAmt = 0;
      double sumpaidAmt = 0;

      for (int i = 0; i < paymentArray.length; i++) {
        final String payName = paymentArray[i][0];
        paidAmt = paymentArray[i][1].toDouble();
        String strPaidAmt = paidAmt.toString();
        strPaidAmt =
            addSpace(strPaidAmt, 39 - payName.length - strPaidAmt.length);

        preview += '$payName $strPaidAmt\n';

        sumpaidAmt += paidAmt;
      }

      double changeAmt = paymentArray[paymentArray.length - 1][2].toDouble();
      if (changeAmt == 0) {
        changeAmt = gTotal - sumpaidAmt;
        String strChange = changeAmt.toString();
        strChange = addSpace(strChange, 32 - strChange.length);

        preview += 'Balance $strChange\n\n';
      } else {
        String strChange = changeAmt.toString();
        strChange = addSpace(strChange, 33 - strChange.length);

        preview += 'Change $strChange\n\n';
      }
    }

    preview += '${addChar('=', 40)}\n';
    preview += '             Closed Bill\n';
    preview += '${addChar('=', 40)}\n';
    return preview;
  }

  Future<String> getOpenBill(int printSNo) async {
    final List<List<String>> scArray =
        await paymentRepository.getSalesCatData(printSNo);

    final List<List<String>> salesArray =
        await paymentRepository.getOrderStatusBySNo(printSNo);
    final String pTblNo = salesArray[0][0];
    final int pSplitNo = salesArray[0][1].toInt();
    final int pCover = salesArray[0][2].toInt();
    final String pRcptNo = salesArray[0][3];

    final List<String> totalItemArray =
        await paymentRepository.getTotalItem(printSNo);
    final List<List<String>> paymentArray =
        await paymentRepository.getPaymentData(printSNo);
    final List<List<String>> promoArray =
        await paymentRepository.getPromotionData(printSNo);
    final List<double> priceArray = await paymentRepository.getAmountOrder(
        printSNo, pSplitNo, pTblNo.toInt(), POSDefault.TaxInclusive);

    double taxTotal = 0;
    final String dateStr = currentDateTime('dd/MM/yyyy HH:mm');
    String tempText = '';

    tempText += '${POSDtls.ScreenHeader1}\n';
    tempText += '${POSDtls.ScreenHeader2}\n';
    tempText += '${POSDtls.ScreenHeader3}\n';
    tempText += '\n';
    tempText += '\n';
    tempText += '$pTblNo\n';
    tempText += '\n';

    final String pax = 'Pax: $pCover';
    final String oprtName = 'OP:${GlobalConfig.operatorName}';
    final String temp = addSpace(oprtName, 38 - pax.length - oprtName.length);
    tempText += '$pax$temp\n';
    tempText += '\n';

    final String posTitle = 'POS Title:${POSDtls.strPOSTitle}';
    tempText += '$posTitle\n';
    tempText += '\n';

    final String rcptStr = 'Rcpt#:$pRcptNo';
    final String datePrint =
        addSpace(dateStr, 38 - rcptStr.length - dateStr.length);
    tempText += '$rcptStr$datePrint\n';
    tempText += '\n';

    tempText += '${addDash(38)}\n';
    tempText += '\n';

    double stotal = priceArray[2];
    final double itemtotal = stotal;

    for (int i = 0; i < scArray.length; i++) {
      final String ctgName = scArray[i][0];
      final List<List<String>> itemArray =
          await paymentRepository.getItemData(printSNo, ctgName);

      final String dash = addDash((36 - ctgName.length) ~/ 2);
      tempText += '$dash$ctgName$dash-\n';

      for (int j = 0; j < itemArray.length; j++) {
        final double qty = itemArray[j][0].toDouble();
        final String tempIName = itemArray[j][1];
        final double iAmount = itemArray[j][2].toDouble();
        final bool prep = itemArray[j][3].toBool();
        String discType = itemArray[j][4];
        final double disc = itemArray[j][5].toDouble();
        String promoType = itemArray[j][6];
        final double promo = itemArray[j][7].toDouble();

        String iName = '', iName2 = '', tempIName2 = '';

        if (!POSDtls.printZeroPrice) {
          if (iAmount == 0) {
            continue;
          }
        }

        if (prep && !POSDtls.PrintPrepWithPrice) {
          if (iAmount == 0) {
            continue;
          }
        }

        if (tempIName.length > 20) {
          tempIName2 = tempIName.substring(20);
          iName = tempIName.substring(0, 20);
          iName2 = addSpace(iName2, 4);
        }

        String strIAmount = iAmount.toString();
        String strQty = qty.toString();
        if (qty != 0 && !prep) {
          strQty = addSpace(strQty, 3 - strQty.length);
          iName = addSpace(tempIName, 1);
          strIAmount =
              addSpace(strIAmount, 35 - iName.length - strIAmount.length);
        } else if (prep) {
          if (POSDtls.PrintPrepWithPrice) {
            strQty = addSpace(strQty, 3 - strQty.length);
            iName = addSpace(tempIName, 1);
            strIAmount =
                addSpace(strIAmount, 29 - iName.length - strIAmount.length);
            tempText += '     *';
          }
        } else {
          strQty = '0';
          strQty = addSpace(strQty, 3 - strQty.length);
          iName = addSpace(tempIName, 4);
          strIAmount =
              addSpace(strIAmount, 37 - iName.length - strIAmount.length);
        }

        tempText += '$strQty$iName$strIAmount\n';
        if (tempIName2.isNotEmpty) {
          tempText += '$iName2\n';
        }

        if (discType.isNotEmpty && discType != 'FOC Item') {
          discType = addSpace(discType, 4);
          String strDisc = disc.toString();
          strDisc = '( $strDisc)';
          strDisc = addSpace(strDisc, 37 - discType.length - strDisc.length);

          tempText += '$discType$strDisc\n';

          stotal -= disc;
        }

        if (promo != 0) {
          if (POSDtls.PrintPrmnDtls) {
            promoType = addSpace(promoType, 4);
            String strPromo = promo.toString();
            strPromo = '( $strPromo)';
            strPromo =
                addSpace(strPromo, 38 - promoType.length - strPromo.length);

            tempText += '$promoType$strPromo\n';
          }

          stotal -= promo;
        }
      }
    }

    if (promoArray.isNotEmpty) {
      final String title = addSpace('ITEMS TOTAL', 4);
      String strItemTotal = itemtotal.toString();
      strItemTotal =
          addSpace(strItemTotal, 37 - title.length - strItemTotal.length);

      tempText += '${addDash(38)}\n';
      tempText += ' $title$strItemTotal\n';

      for (int i = 0; i < promoArray.length; i++) {
        String pName = promoArray[i][0];
        final double pValue = promoArray[i][1].toDouble();
        String strPValue = pValue.toString();

        strPValue = '( $strPValue)';
        pName = addSpace(pName, 4);
        strPValue = addSpace(strPValue, 37 - pName.length - strPValue.length);

        tempText += ' $pName$strPValue\n';
      }
    }

    tempText += '${addDash(38)}\n';
    if (stotal > 0) {
      String strSTotal = stotal.toString();
      strSTotal = addSpace(strSTotal, 24 - strSTotal.length);
      tempText += '     SUBTOTAL $strSTotal\n';
    }

    tempText += '${addDash(38)}\n';
    if (stotal > 0) {
      String strSTotal = stotal.toString();
      strSTotal = addSpace(strSTotal, 24 - strSTotal.length);
      tempText += '     SUBTOTAL $strSTotal';

      final List<List<String>> taxArray =
          await paymentRepository.getPrintTax(printSNo);
      final List<Map<String, dynamic>> tTitleArray =
          await paymentRepository.getTaxRateData();

      if (POSDtls.PrintTax) {
        for (int i = 0; i < tTitleArray.length; i++) {
          final int taxCode = dynamicToInt(tTitleArray[i]['TaxCode']);
          String taxName = tTitleArray[i]['Title'].toString();

          final double taxValue = taxArray[0][taxCode].toDouble();
          if (taxValue > 0) {
            taxName = addSpace(taxName, 5);
            String strTaxValue = taxValue.toString();
            strTaxValue =
                addSpace(strTaxValue, 37 - taxName.length - strTaxValue.length);

            tempText += '$taxName$strTaxValue\n';
          }
          taxTotal += taxValue;
        }
      }

      if (POSDtls.PrintTotalTax) {
        final String title = addSpace(POSDtls.TotalTaxTitle, 5);
        String strTaxTotal = taxTotal.toString();
        strTaxTotal =
            addSpace(strTaxTotal, 37 - title.length - strTaxTotal.length);

        tempText += '$title$strTaxTotal\n';
      }

      tempText += '${addDash(38)}\n';
    } else {
      String strSTotal = stotal.toString();
      strSTotal = addSpace(strSTotal, 24 - strSTotal.length);

      tempText += '     SUBTOTAL $strSTotal\n';
    }

    final double gtotal = priceArray[0];
    String strGTotal = stotal.toString();
    strGTotal = addSpace(strGTotal, 30 - strGTotal.length);

    tempText += '  TOTAL $strGTotal\n';

    String totalItem = 'Total Item : ${totalItemArray[0][0]}';
    totalItem = addSpace(totalItem, 5);

    String totalQty = 'Total Qty : ${totalItemArray[0][1]}';
    totalQty = addSpace(totalQty, 38 - totalItem.length - totalQty.length);

    tempText += '$totalItem$totalQty\n';
    double sumpaidAmt = 0;
    for (int i = 0; i < paymentArray.length; i++) {
      final String payName = paymentArray[i][0];
      final double payAmt = paymentArray[i][1].toDouble();
      String strPayAmt = payAmt.toString();
      strPayAmt = addSpace(strPayAmt, 37 - payName.length - strPayAmt.length);

      tempText += '$payName $strPayAmt\n';

      sumpaidAmt += payAmt;
    }

    double changeAmt = paymentArray[paymentArray.length - 1][2].toDouble();
    if (changeAmt == 0) {
      changeAmt = gtotal - sumpaidAmt;
      String strChange = changeAmt.toString();
      strChange = addSpace(strChange, 31 - strChange.length);

      tempText += 'Balance $strChange\n';
      tempText += '\n';
    } else {
      String strChangeAmt = changeAmt.toString();
      strChangeAmt = addSpace(strChangeAmt, 31 - strChangeAmt.length);

      tempText += 'Change $strChangeAmt\n';
      tempText += '\n';
    }

    tempText += '${addDash(38)}\n';
    tempText += 'Closed Bill \n';
    tempText += '${addDash(38)}\n';
    return tempText;
  }

  Future<void> reprintKitchenNotify(int cntCopy, int transID, String tblName,
      String kpTbl, int salesNo, int splitNo, String tableNo) async {
    final List<List<String>> scList = await printRepository.getKPSalesCategory(
        salesNo, splitNo, tblName, kpTbl, transID);
    await kpPrinting(
        salesNo, splitNo, tableNo, tblName, kpTbl, transID, cntCopy);
    if (POSDtls.blnKPPrintMaster) {
      await masterKPPrint(
          salesNo, splitNo, tableNo, tblName, kpTbl, transID, cntCopy);
    }
    for (String printData in printArr) {
      await doPrint(2, 0, printData);
    }
    printArr.clear();
    await printRepository.updateKPPrintItem(salesNo, splitNo);
  }

  Future<void> reprintBillNotify(int tempSNo, String status) async {
    if (status == 'Open Tables') {
      await doPrint(5, tempSNo, '');
    } else {
      await printBill(tempSNo, status);
    }
  }

  List<String> getPrintArray() {
    return printArr;
  }

  void clearPrintArray() {
    printArr.clear();
  }
}
