import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../repository/i_printer_repository.dart';
import '../utils/printer_util.dart';
import 'printer_state.dart';

@Injectable()
class PrinterStateNotifier extends StateNotifier<PrinterState> {
  PrinterStateNotifier(this.printerRepository) : super(PrinterLoadingState());
  final IPrinterRepository printerRepository;
  List<String> printArr = <String>[];

  Future<void> kpPrinting(int kpsNo, int kpsPlNo, String kpTblNo,
      String tblName, String kpTblName, int transID, int countReprint) async {
    String tempCtgName = '', tempIName = '', kitchenPrint = '';
    int kpNo = 0, tempCtgID = 0;
    bool blnIndividual;
    double tempQty = 0;

    List<List<String>> kpscArray = await printerRepository.getKPSalesCategory(
        kpsNo, kpsPlNo, tblName, kpTblName, transID);
    for (List<String> kpsc in kpscArray) {
      tempCtgName = kpsc[0];
      tempCtgID = kpsc[1].toInt();

      List<List<String>> kpArray = await printerRepository.getKPNo(
          kpsNo, kpsPlNo, tempCtgName, tblName, kpTblName, transID);
      for (List<String> kp in kpArray) {
        kpNo = kp[0].toInt();
        if (POSDtls.blnKPPartialConsolidate) {
          kitchenPrint = await printerRepository.generateKP(
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
              await printerRepository.getKPIndividualItems(kpsNo, kpsPlNo, kpNo,
                  kpTblNo, tempCtgName, tblName, kpTblName, transID);
          for (List<String> indvItem in indvItems) {
            tempIName = indvItem[1];
            tempQty = indvItem[3].toDouble();
            blnIndividual = indvItem[7].toBool();

            kitchenPrint = await printerRepository.generateIndividualKP(
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

          kitchenPrint = await printerRepository.generateKPIndividual(
              kpsNo,
              kpsPlNo,
              kpTblNo,
              tempCtgName,
              kpNo,
              tblName,
              kpTblName,
              transID,
              countReprint);
        }
        if (kitchenPrint.isNotEmpty) {
          printArr.add(kitchenPrint);
        }
      }
    }
  }

  Future<void> masterKPPrint(int mKpsNo, int mKpSplNo, String mKpTblNo,
      String tblName, String kpTblName, int transID, int countReprint) async {
    List<List<String>> data =
        await printerRepository.getMasterKPID(POSDtls.deviceNo);
    if (data.isNotEmpty) {
      for (int i = 0; i < 3; i++) {
        int masterKPID = data[0][i].toInt();
        List<List<String>> scArr = await printerRepository.getMasterKPSC(
            mKpsNo, mKpSplNo, masterKPID, i + 1);
        for (int i = 0; i < scArr.length; i++) {
          String ctgName = scArr[i][1];
          int ctgId = scArr[i][0].toInt();
          // String strMasterKP = await printerRepository.generateMasterKP(
          //     masterKPID, ctgName, ctgId, mKpTblNo, mKpsNo, mKpSplNo, i + 1);
          // printArray.add(strMasterKP);
        }
      }
    }
  }

  Future<void> doPrint() async {
    List<List<String>> kpscArray = await printerRepository.getKPSalesCategory(
        GlobalConfig.salesNo, GlobalConfig.splitNo, 'HeldItems', 'KPStatus', 0);
    if (kpscArray.isNotEmpty) {
      await kpPrinting(GlobalConfig.salesNo, GlobalConfig.splitNo,
          GlobalConfig.tableNo, 'HeldItems', 'KPStatus', 0, 0);

      if (POSDtls.blnKPPrintMaster) {
        await masterKPPrint(GlobalConfig.salesNo, GlobalConfig.splitNo,
            GlobalConfig.tableNo, 'HeldItems', 'KPStatus', 0, 0);
      }
      PrinterUtil printerUtil = PrinterUtil();
      for (String printData in printArr) {
        // Print Action
        printerUtil.print(2, 0, printData);
      }
      printArr.clear();
      await printerRepository.updateKPPrintItem(
          GlobalConfig.salesNo, GlobalConfig.splitNo);
    }
  }
}
