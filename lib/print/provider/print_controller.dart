import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../../common/services/printer_manager.dart';
import '../../common/utils/strings_util.dart';
import '../../common/utils/type_util.dart';
import '../../payment/repository/i_payment_repository.dart';
import '../repository/i_print_repository.dart';
import 'print_state.dart';

@Injectable()
class PrintController extends StateNotifier<PrintState>
    with StringUtil, TypeUtil {
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

    List<List<String>> kpscArray = await printRepository.getKPSalesCategory(
        kpsNo, kpsPlNo, tblName, kpTblName, transID);
    for (List<String> kpsc in kpscArray) {
      tempCtgName = kpsc[0];
      tempCtgID = kpsc[1].toInt();

      List<List<String>> kpArray = await printRepository.getKPNo(
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
          List<List<String>> indvItems =
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
    List<List<String>> data =
        await printRepository.getMasterKPID(POSDtls.deviceNo);
    if (data.isNotEmpty) {
      for (int i = 0; i < 3; i++) {
        int masterKPID = data[0][i].toInt();
        List<List<String>> scArr = await printRepository.getMasterKPSC(
            mKpsNo, mKpSplNo, masterKPID, i + 1);
        for (int i = 0; i < scArr.length; i++) {
          String ctgName = scArr[i][1];
          int ctgId = scArr[i][0].toInt();
          String strMasterKP = await printRepository.generateMasterKP(
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
        throw Exception('There is no printer connected');
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
          await printerManager.print(printData);
        }
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> printBill(int printSNo, String status) async {
    try {
      if (status == 'Close Tables') {
        await doPrint(3, printSNo, 'Close');
      } else if (status == 'Refund') {
        await doPrint(3, printSNo, 'Refund');
      } else if (status == 'Void Tables') {
        await doPrint(3, printSNo, 'AllVoid');
      }
      state = PrintSuccessState();
    } catch (e) {
      state = PrintErrorState(errMsg: e.toString());
    }
  }

  Future<void> kpPrint() async {
    try {
      List<List<String>> kpscArray = await printRepository.getKPSalesCategory(
          GlobalConfig.salesNo,
          GlobalConfig.splitNo,
          'HeldItems',
          'KPStatus',
          0);
      if (kpscArray.isNotEmpty) {
        await kpPrinting(GlobalConfig.salesNo, GlobalConfig.splitNo,
            GlobalConfig.tableNo, 'HeldItems', 'KPStatus', 0, 0);

        if (POSDtls.blnKPPrintMaster) {
          await masterKPPrint(GlobalConfig.salesNo, GlobalConfig.splitNo,
              GlobalConfig.tableNo, 'HeldItems', 'KPStatus', 0, 0);
        }

        if (printerManager.getPrinters().isEmpty) {
          printArr.clear();
          state = PrintErrorState(errMsg: 'There is no printer connected');
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

    if (printStatus == 'Refund') {
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

    String tblNo = priceArray[0][4];
    double taxTotal = 0;

    DateFormat format = DateFormat('dd/MM/yyyy HH:mm');
    String dateStr = format.format(DateTime.now());
    int coverPrint = priceArray[0][2].toInt();
    String rcptNoPrint = priceArray[0][3];
    String tempText = '';

    tempText += '${textPrintFormat('N', 'C', '1')}${POSDtls.ScreenHeader1}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}${POSDtls.ScreenHeader2}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}${POSDtls.ScreenHeader3}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}$tblNo\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    String pax = 'Pax: $coverPrint';
    String oprtName = 'OP: ${GlobalConfig.operatorName}';
    String temp = addSpace(oprtName, 38 - pax.length - oprtName.length);
    tempText += '${textPrintFormat('N', 'C', '1')}$pax$temp\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    String posTitle = 'POS Title: ${POSDtls.strPOSTitle}';
    tempText += '${textPrintFormat('N', 'C', '1')}$posTitle\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    String rcptStr = 'Rcpt#: $rcptNoPrint';
    String datePrint = addSpace(dateStr, 38 - rcptStr.length - dateStr.length);
    tempText += '${textPrintFormat('N', 'C', '1')}$rcptStr$datePrint\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    tempText += '${textPrintFormat('N', 'C', '1')}${addDash(38)}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    double sTotal = priceArray[0][0].toDouble();
    double itemTotal = sTotal;

    for (int i = 0; i < scArray.length; i++) {
      String ctgName = scArray[i][0];
      List<List<String>> itemArray =
          await paymentRepository.getPrintItem(printSNo, ctgName);

      String dash = addDash((36 - ctgName.length) ~/ 2);
      tempText += '${textPrintFormat('N', 'C', '1')}$dash$ctgName$dash\n';

      for (int j = 0; j < itemArray.length; j++) {
        String discType = itemArray[j][4];
        String promoType = itemArray[j][6];
        double disc = itemArray[j][5].toDouble();
        double promo = itemArray[j][7].toDouble();
        int qty = itemArray[j][0].toInt();
        String tempIName = itemArray[j][1];
        bool prep = itemArray[j][3].toBool();
        double iAmount = itemArray[j][2].toDouble();

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
    if (printStatus == 'AllVoid') {
      tempText += '${textPrintFormat('N', 'C', '1')}${addDash(38)}\n';
      tempText +=
          '${textPrintFormat('N', 'C', '1')} ********* ALL VOID *********n';
      tempText += '${textPrintFormat('N', 'C', '1')}\n';
    } else {
      if (promoArray.isNotEmpty) {
        String title = addSpace('ITEMS TOTAL', 4);
        String strItemTotal = itemTotal.toString();
        strItemTotal =
            addSpace(strItemTotal, 37 - title.length - strItemTotal.length);

        tempText += '${textPrintFormat('N', 'C', '1')}${addDash(38)}\n';
        tempText += '${textPrintFormat('N', 'C', '1')} $title $strItemTotal\n';
        for (int i = 0; i < promoArray.length; i++) {
          String pName = promoArray[i][0];
          double pValue = promoArray[i][1].toDouble();
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
        String dbName = discArray[0][0];
        double dbValue = discArray[0][1].toDouble();
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

        List<List<String>> taxArray =
            await paymentRepository.getPrintTax(printSNo);
        List<Map<String, dynamic>> tTitleArray =
            await paymentRepository.getTaxRateData();

        if (POSDtls.PrintTax) {
          for (int i = 0; i < tTitleArray.length; i++) {
            int taxCode = dynamicToInt(tTitleArray[i]['TaxCode']);
            String taxName = tTitleArray[i]['Title'].toString();
            double taxValue = taxArray[0][taxCode].toDouble();
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
          String title = addSpace(POSDtls.TotalTaxTitle, 5);
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
        double gTotal = priceArray[0][1].toDouble();
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
        String payName = paymentArray[i][0];
        double payAmt = paymentArray[i][1].toDouble();
        String strPayAmt = payAmt.toString();
        strPayAmt = addSpace(strPayAmt, 37 - payName.length - strPayAmt.length);
        tempText += '${textPrintFormat('N', 'C', '1')} $payName$strPayAmt\n';
      }

      if (printStatus == 'Refund') {
        String rcptRfnd = refundArray[0][0];
        tempText +=
            '${textPrintFormat('N', 'C', '1')} ********* REFUND BILL *********\n';
        tempText +=
            '${textPrintFormat('N', 'C', '1')} RFND of Rcpt#$rcptRfnd\n';
      } else if (printStatus == 'Close') {
        double changeAmt = paymentArray[paymentArray.length - 1][2].toDouble();
        String strChangeAmt = changeAmt.toString();
        tempText += '${textPrintFormat('N', 'C', '1')} Change $strChangeAmt\n';
        tempText += '${textPrintFormat('N', 'C', '1')}\n';
      }
    }
    tempText += '${textPrintFormat('N', 'C', '1')} ${addDash(38)}\n';
    tempText += '${textPrintFormat('N', 'C', '1')} Closed Bill\n';
    tempText += '${textPrintFormat('N', 'C', '1')} ${addDash(38)}\n';
    return tempText;
  }

  Future<String> getBillForPreview(int printSNo, int splitNo, int cover,
      String tableNo, String rcptNo) async {
    List<List<String>> refundArray = <List<String>>[];

    final List<List<String>> scArray =
        await paymentRepository.getPrintCategory(printSNo);
    final List<List<String>> discArray =
        await paymentRepository.getPrintBillDisc(printSNo);
    final List<double> priceArray = await paymentRepository.getAmountOrder(
        printSNo, splitNo, tableNo.toInt(), POSDefault.taxInclusive);
    final List<List<String>> countArray =
        await paymentRepository.getTotalItemQty(printSNo);
    final List<List<String>> paymentArray =
        await paymentRepository.getPrintPayment(printSNo);
    final List<List<String>> promoArray =
        await paymentRepository.getPrintPromo(printSNo);

    String tblNo = 'TABLE: $tableNo';
    double taxTotal = 0;

    DateFormat format = DateFormat('dd/MM/yyyy HH:mm');
    String dateStr = format.format(DateTime.now());
    int coverPrint = cover;
    String rcptNoPrint = rcptNo;
    String tempText = '';

    tempText += '${textPrintFormat('N', 'C', '1')}${POSDtls.ScreenHeader1}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}${POSDtls.ScreenHeader2}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}${POSDtls.ScreenHeader3}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}$tblNo\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    String pax = 'Pax: $coverPrint';
    String oprtName = 'OP: ${GlobalConfig.operatorName}';
    String temp = addSpace(oprtName, 38 - pax.length - oprtName.length);
    tempText += '${textPrintFormat('N', 'C', '1')}$pax$temp\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    String posTitle = 'POS Title: ${POSDtls.strPOSTitle}';
    tempText += '${textPrintFormat('N', 'C', '1')}$posTitle\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    String rcptStr = 'Rcpt#: $rcptNoPrint';
    String datePrint = addSpace(dateStr, 38 - rcptStr.length - dateStr.length);
    tempText += '${textPrintFormat('N', 'C', '1')}$rcptStr$datePrint\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    tempText += '${textPrintFormat('N', 'C', '1')}${addDash(38)}\n';
    tempText += '${textPrintFormat('N', 'C', '1')}\n';

    double sTotal = priceArray[0];
    double itemTotal = sTotal;

    for (int i = 0; i < scArray.length; i++) {
      String ctgName = scArray[i][0];
      List<List<String>> itemArray =
          await paymentRepository.getPrintItem(printSNo, ctgName);

      String dash = addDash((36 - ctgName.length) ~/ 2);
      tempText += '${textPrintFormat('N', 'C', '1')}$dash$ctgName$dash\n';

      for (int j = 0; j < itemArray.length; j++) {
        String discType = itemArray[j][4];
        String promoType = itemArray[j][6];
        double disc = itemArray[j][5].toDouble();
        double promo = itemArray[j][7].toDouble();
        int qty = itemArray[j][0].toInt();
        String tempIName = itemArray[j][1];
        bool prep = itemArray[j][3].toBool();
        double iAmount = itemArray[j][2].toDouble();

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
    {
      if (promoArray.isNotEmpty) {
        String title = addSpace('ITEMS TOTAL', 4);
        String strItemTotal = itemTotal.toString();
        strItemTotal =
            addSpace(strItemTotal, 37 - title.length - strItemTotal.length);

        tempText += '${textPrintFormat('N', 'C', '1')}${addDash(38)}\n';
        tempText += '${textPrintFormat('N', 'C', '1')} $title $strItemTotal\n';
        for (int i = 0; i < promoArray.length; i++) {
          String pName = promoArray[i][0];
          double pValue = promoArray[i][1].toDouble();
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
        String dbName = discArray[0][0];
        double dbValue = discArray[0][1].toDouble();
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

        List<List<String>> taxArray =
            await paymentRepository.getPrintTax(printSNo);
        List<Map<String, dynamic>> tTitleArray =
            await paymentRepository.getTaxRateData();

        if (POSDtls.PrintTax) {
          for (int i = 0; i < tTitleArray.length; i++) {
            int taxCode = dynamicToInt(tTitleArray[i]['TaxCode']);
            String taxName = tTitleArray[i]['Title'].toString();
            double taxValue = taxArray[0][taxCode].toDouble();
            if (taxValue > 0) {
              taxName = addSpace(taxName, 5);
              String strTaxValue = taxValue.toString();

              tempText +=
                  '${textPrintFormat('N', 'C', '1')}$taxName$strTaxValue\n';
            }
            taxTotal += taxValue;
          }
        }

        if (POSDtls.PrintTotalTax) {
          String title = addSpace(POSDtls.TotalTaxTitle, 5);
          String strTaxTotal = taxTotal.toString();

          tempText += '${textPrintFormat('N', 'C', '1')} ${addDash(38)}\n';
        }
      } else {
        String strSTotal = sTotal.toString();
        strSTotal = addSpace(strSTotal, 24 - strSTotal.length);
        tempText +=
            '${textPrintFormat('N', 'C', '1')}       SUBTOTAL $strSTotal\n';
      }
      if (taxTotal == 0) {
        String strSTotal = sTotal.toString();
        strSTotal = addSpace(strSTotal, 30 - strSTotal.length);
        tempText +=
            '${textPrintFormat('N', 'C', '1')}       TOTAL $strSTotal\n';
      } else {
        double gTotal = priceArray[1];
        String strGTotal = sTotal.toString();
        strGTotal = addSpace(strGTotal, 30 - strGTotal.length);
        tempText +=
            '${textPrintFormat('N', 'C', '1')}       TOTAL $strGTotal\n';
      }

      String totalItem = 'Total Item : ${countArray[0][0]}';
      totalItem = addSpace(totalItem, 5);

      String totalQty = 'Total Qty : ${countArray[0][1]}';
      totalQty = addSpace(totalQty, 38 - totalItem.length - totalQty.length);
      tempText += '${textPrintFormat('N', 'C', '1')} $totalItem$totalQty\n';

      for (int i = 0; i < paymentArray.length; i++) {
        String payName = paymentArray[i][0];
        double payAmt = paymentArray[i][1].toDouble();
        String strPayAmt = payAmt.toString();
        strPayAmt = addSpace(strPayAmt, 37 - payName.length - strPayAmt.length);
        tempText += '${textPrintFormat('N', 'C', '1')} $payName$strPayAmt\n';
      }
    }
    tempText += '${textPrintFormat('N', 'C', '1')} ${addDash(38)}\n';
    tempText += '${textPrintFormat('N', 'C', '1')} Closed Bill\n';
    tempText += '${textPrintFormat('N', 'C', '1')} ${addDash(38)}\n';
    return tempText;
  }

  Future<String> getOpenBill(int printSNo) async {
    return '';
  }

  Future<void> reprintKitchenNotify(int cntCopy, int transID, String tblName,
      String kpTbl, int salesNo, int splitNo, String tableNo) async {
    List<List<String>> scList = await printRepository.getKPSalesCategory(
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
}
