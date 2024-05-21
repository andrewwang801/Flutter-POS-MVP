import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../common/GlobalConfig.dart';
import '../../common/helper/db_helper.dart';
import '../../common/utils/strings_util.dart';
import '../../common/utils/type_util.dart';
import '../../common/extension/string_extension.dart';
import 'i_printer_repository.dart';

@Injectable(as: IPrinterRepository)
class PrinterLocalRepository
    with TypeUtil, StringUtil
    implements IPrinterRepository {
  PrinterLocalRepository({required this.dbHelper});

  final LocalDBHelper dbHelper;

  @override
  Future<List<List<String>>> getKPIndividual(
      int salesNo,
      int splitNo,
      int kpNo,
      String tableNo,
      String categoryName,
      String tableName,
      String kpTableName,
      int transID) async {
    final Database dbHandler = await dbHelper.database;

    String addquery = '', addquery2 = '';
    int tblHold = 0;
    if (tableName == 'temp_ReprintKitchen') {
      addquery = 'AND (K.Trans_ID = H.Trans_ID)';
      addquery2 = 'AND H.Trans_ID = $transID';
      tblHold = 1;
    }

    final String query =
        "SELECT H.PLUNo, H.ItemName, H.ItemName_Chinese, H.Quantity, H.ItemSeqNo, H.Preparation, H.TransStatus, PLU.IndividualPrint, H.SalesNo, H.SalesRef, H.PLUSalesRef, H.SplitNo, H.TableNo, H.ItemAmount, SalesCategory.CategoryName, GroupName, DepartmentName FROM $kpTableName K INNER JOIN $tableName H ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) $addquery INNER JOIN PLU ON (H.PLUNo = PLU.PLUNumber) INNER JOIN SalesCategory ON (H.CategoryId = SalesCategory.CategoryId) INNER JOIN Departments ON Departments.DepartmentNo = PLU.Department INNER JOIN [Group] ON Departments.GroupNo=[Group].GroupNo WHERE K.SalesNo = $salesNo AND K.SplitNo = $splitNo AND K.PrintToKp = 1 AND K.KPNo = $kpNo AND (H.TransStatus = 'V' OR H.TransStatus = ' ' OR H.TransStatus = 'M') AND H.SeatNo = 0 AND FunctionId <> 33 AND PLU.IndividualPrint = 0 AND (H.PromotionType <> 'COUPONS' OR H.PromotionType IS NULL) $addquery2 GROUP BY SalesCategory.CategoryName, H.PLUNo, H.ItemName, H.ItemName_Chinese, H.Quantity, H.ItemSeqNo, H.Preparation, H.TransStatus, H.PLUSalesRef, PLU.IndividualPrint, H.SalesNo, H.SalesRef, H.PLUSalesRef, H.SplitNo, H.TableNo, H.ItemAmount, GroupName, DepartmentName ORDER BY SalesCategory.CategoryName, H.PLUSalesRef, H.ItemSeqNo";

    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<String> generateKPIndividual(
      int salesNo,
      int splitNo,
      String tableNo,
      String ctgName,
      int kpID,
      String tblName,
      String kpTblName,
      int transID,
      int countCopy) async {
    final Database dbHandler = await dbHelper.database;

    String PrintKPContent = '', PrintKPHdr = '', PrintKPFooter = '';
    final int PrintLineSpace = 20;

    final String date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final String dash = addDash(PrintLineSpace);
    final bool AutoCheck = await findAutoCheckOp();

    PrintKPHdr += "${textPrintFormat('N', 'L', '2')}$ctgName\n";
    if (POSDtls.blnKPPrintID) {
      final String strKPId = 'KPID : $kpID';
      //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
      PrintKPHdr += "${textPrintFormat('N', 'L', '2')}$strKPId\n";
    }

    if (AutoCheck) {
      //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
      PrintKPHdr += '${textPrintFormat('N', 'L', '2')}$tableNo\n';
    } else {
      //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
      PrintKPHdr +=
          '${textPrintFormat('N', 'L', '2')}${POSDtls.LabelTable}$tableNo\n';
    }

    if (POSDtls.PrintTblRemarks) {
      final String Remarks = await getRemarks(salesNo, splitNo, tblName);
      if (Remarks.isNotEmpty) {
        final String temp = 'RE : $Remarks';
        //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
        PrintKPHdr += "${textPrintFormat("N", "L", "2")}$temp\n";
      }
    }

    //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
    PrintKPHdr += "${textPrintFormat("N", "L", "1")}$dash\n";

    final List<List<String>> KPItemArray = await getKPIndividual(
        salesNo, splitNo, kpID, tableNo, ctgName, tblName, kpTblName, transID);
    String qty = '', itemname = '';
    for (int i = 0; i < KPItemArray.length; i++) {
      if (i.isOdd /* % 2 == 0 */) {
        qty = KPItemArray[i][3];
        if (qty != '0') {
          qty = addSpace(qty, 3 - qty.length);
          PrintKPContent += '${textPrintFormat("N", "L", "2")}$qty';
        }
      } else {
        itemname = KPItemArray[i][1];
        if (itemname.length > (PrintLineSpace - 4)) {
          String iname2 = itemname.substring(PrintLineSpace - 4);
          itemname = itemname.substring(0, PrintLineSpace - 4);

          if (qty == '0') {
            itemname = addSpace(itemname, 3);
          }
          iname2 = addSpace(iname2, 3);
          PrintKPContent += ' $itemname\n';
          PrintKPContent += "${textPrintFormat("N", "L", "2")}$iname2\n";
          PrintKPContent += "${textPrintFormat("N", "L", "2")}\n";
        } else {
          if (qty == '0') {
            itemname = addSpace(itemname, 3);
          }
          PrintKPContent += ' $itemname\n';
          PrintKPContent += "${textPrintFormat("N", "L", "2")}\n";
        }
      }
    }

    PrintKPFooter += "${textPrintFormat("N", "L", "1")}$dash\n";
    if (POSDtls.blnKPPrintCover) {
      final int Cover = await getCover(salesNo, splitNo);
      final String strCover = 'Covers : $Cover';
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}$strCover\n";
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}\n";
    }

    PrintKPFooter +=
        '${textPrintFormat("N", "L", "2")}${POSDtls.strSalesAreaID}" OP: "${GlobalConfig.operatorName}"\n"';

    if (tblName == 'temp_ReprintKitchen') {
      final String reprintKitchen = 'RE-PRINT RECEIPT $countCopy';
      //PrintKPFooter += TextPrintFormat("N", "L", "2") + "\n";
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}$reprintKitchen\n";
    }

    PrintKPFooter += "${textPrintFormat("N", "L", "2")}$date\n";
    //PrintKPFooter += TextPrintFormat("N", "L", "2") + "\n";

    final String RcptNo = await getRcptNo(salesNo, splitNo);
    if (RcptNo != '') {
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}$RcptNo\n";
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}\n";
    }

    if (POSDefault.blnPrintKPRfnd) {
      if (GlobalConfig.TransMode == 'RFND') {
        final String rfnd = '********REFUND********';
        PrintKPFooter += "${textPrintFormat("N", "L", "2")}$RcptNo\n";
      }
    }

    String PrintKPAll = '';
    if (KPItemArray.isNotEmpty) {
      PrintKPAll += PrintKPHdr;
      PrintKPAll += PrintKPContent;
      PrintKPAll += PrintKPFooter;
    }

    return PrintKPAll;
  }

  @override
  Future<String> generateKP(
      int salesNo,
      int splitNo,
      String tableNo,
      String ctgName,
      int kpID,
      String tblName,
      String kpTblName,
      int transID,
      int countCopy) async {
    final Database dbHandler = await dbHelper.database;

    String PrintKPContent = '', PrintKPHdr = '', PrintKPFooter = '';
    final int PrintLineSpace = 20;

    final String date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final String dash = addDash(PrintLineSpace);
    final bool AutoCheck = await findAutoCheckOp();

    PrintKPHdr += "${textPrintFormat('N', 'L', '2')}$ctgName\n";
    if (POSDtls.blnKPPrintID) {
      final String strKPId = 'KPID : $kpID';
      //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
      PrintKPHdr += "${textPrintFormat('N', 'L', '2')}$strKPId\n";
    }

    if (AutoCheck) {
      //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
      PrintKPHdr += '${textPrintFormat('N', 'L', '2')}$tableNo\n';
    } else {
      //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
      PrintKPHdr +=
          '${textPrintFormat('N', 'L', '2')}${POSDtls.LabelTable}$tableNo\n';
    }

    if (POSDtls.PrintTblRemarks) {
      final String Remarks = await getRemarks(salesNo, splitNo, tblName);
      if (Remarks.isNotEmpty) {
        final String temp = 'RE : $Remarks';
        //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
        PrintKPHdr += "${textPrintFormat("N", "L", "2")}$temp\n";
      }
    }

    //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
    PrintKPHdr += "${textPrintFormat("N", "L", "1")}$dash\n";

    final List<String> KPItemArray = await getKPPrintItems(
        salesNo, splitNo, kpID, tableNo, ctgName, tblName, kpTblName, transID);
    String qty = '', itemname = '';
    for (int i = 0; i < KPItemArray.length; i++) {
      if (i.isOdd /* % 2 == 0 */) {
        qty = KPItemArray[i];
        if (qty != '0') {
          qty = addSpace(qty, 3 - qty.length);
          PrintKPContent += '${textPrintFormat("N", "L", "2")}$qty';
        }
      } else {
        itemname = KPItemArray[i];
        if (itemname.length > (PrintLineSpace - 4)) {
          String iname2 = itemname.substring(PrintLineSpace - 4);
          itemname = itemname.substring(0, PrintLineSpace - 4);

          if (qty == '0') {
            itemname = addSpace(itemname, 3);
          }
          iname2 = addSpace(iname2, 3);
          PrintKPContent += ' $itemname\n';
          PrintKPContent += "${textPrintFormat("N", "L", "2")}$iname2\n";
          PrintKPContent += "${textPrintFormat("N", "L", "2")}\n";
        } else {
          if (qty == '0') {
            itemname = addSpace(itemname, 3);
          }
          PrintKPContent += ' $itemname\n';
          PrintKPContent += "${textPrintFormat("N", "L", "2")}\n";
        }
      }
    }

    PrintKPFooter += "${textPrintFormat("N", "L", "1")}$dash\n";
    if (POSDtls.blnKPPrintCover) {
      final int Cover = await getCover(salesNo, splitNo);
      final String strCover = 'Covers : $Cover';
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}$strCover\n";
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}\n";
    }

    PrintKPFooter +=
        '${textPrintFormat("N", "L", "2")}${POSDtls.strSalesAreaID}" OP: "${GlobalConfig.operatorName}"\n"';

    if (tblName == 'temp_ReprintKitchen') {
      final String reprintKitchen = 'RE-PRINT RECEIPT $countCopy';
      //PrintKPFooter += TextPrintFormat("N", "L", "2") + "\n";
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}$reprintKitchen\n";
    }

    PrintKPFooter += "${textPrintFormat("N", "L", "2")}$date\n";
    //PrintKPFooter += TextPrintFormat("N", "L", "2") + "\n";

    final String RcptNo = await getRcptNo(salesNo, splitNo);
    if (RcptNo != '') {
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}$RcptNo\n";
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}\n";
    }

    if (POSDefault.blnPrintKPRfnd) {
      if (GlobalConfig.TransMode == 'RFND') {
        final String rfnd = '********REFUND********';
        PrintKPFooter += "${textPrintFormat("N", "L", "2")}$RcptNo\n";
      }
    }

    String PrintKPAll = '';
    if (KPItemArray.isNotEmpty) {
      PrintKPAll += PrintKPHdr;
      PrintKPAll += PrintKPContent;
      PrintKPAll += PrintKPFooter;
    }

    return PrintKPAll;
  }

  @override
  Future<String> generateIndividualKP(
      int salesNo,
      int splitNo,
      String tableNo,
      String ctgName,
      int kpID,
      String nameIndv,
      double qtyIndv,
      bool indv,
      String tblName,
      String kpTblName,
      int transId,
      int countCopy) async {
    final Database dbHandler = await dbHelper.database;

    final List<List<String>> printSetting = await getPrinterSetting(kpID);
    final int PrintLineSpace = printSetting[0][1].toInt();
    final String dash = addDash(PrintLineSpace);

    String PrintKPHdr = '',
        PrintKPItem = '',
        PrintKPFooter = '',
        PrintKPAll = '';
    final String date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final bool AutoCheck = await findAutoCheckOp();

    PrintKPHdr += "${textPrintFormat("N", "L", "2")}$ctgName\n";
    if (POSDtls.blnKPPrintID) {
      final String strKPId = 'KPID : $kpID';
      //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
      PrintKPHdr += "${textPrintFormat("N", "L", "2")}$strKPId\n";
    }

    if (AutoCheck) {
      //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
      PrintKPHdr += "${textPrintFormat("N", "L", "2")}$tableNo\n";
    } else {
      //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
      PrintKPHdr +=
          "${textPrintFormat("N", "L", "2")}${POSDtls.LabelTable}$tableNo\n";
    }

    if (POSDtls.PrintTblRemarks) {
      final String Remarks = await getRemarks(salesNo, splitNo, tblName);
      if (Remarks != '') {
        final String temp = "RE : $Remarks";
        //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
        PrintKPHdr += "${textPrintFormat("N", "L", "2")}$temp\n";
      }
    }

    //PrintKPHdr += TextPrintFormat("N", "C", "2") + "\n";
    PrintKPHdr += "${textPrintFormat("N", "L", "1")}$dash\n";
    PrintKPHdr += "${textPrintFormat("N", "C", "2")}\n";

    final String strQty =
        addSpace(qtyIndv.toString(), 3 - qtyIndv.toString().length);
    PrintKPItem += "${textPrintFormat("N", "L", "2")}$strQty $nameIndv\n";
    PrintKPItem += "${textPrintFormat("N", "L", "2")}\n";

    PrintKPFooter += "${textPrintFormat("N", "L", "1")}$dash\n";
    if (POSDtls.blnKPPrintCover) {
      final int Cover = await getCover(salesNo, splitNo);
      final String strCover = 'Covers : $Cover';
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}$strCover\n";
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}\n";
    }

    PrintKPFooter +=
        '${textPrintFormat("N", "L", "2")}${POSDtls.strSalesAreaID} OP: ${GlobalConfig.operatorName}\n';

    if (tblName == 'temp_ReprintKitchen') {
      final String reprintKitchen = 'RE-PRINT RECEIPT $countCopy';
      //PrintKPFooter += TextPrintFormat("N", "L", "2") + "\n";
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}$reprintKitchen\n";
    }

    PrintKPFooter += "${textPrintFormat("N", "L", "2")}$date\n";
    //PrintKPFooter += TextPrintFormat("N", "L", "2") + "\n";

    final String RcptNo = await getRcptNo(salesNo, splitNo);
    if (RcptNo != '') {
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}$RcptNo\n";
      PrintKPFooter += "${textPrintFormat("N", "L", "2")}\n";
    }

    if (POSDefault.blnPrintKPRfnd) {
      if (GlobalConfig.TransMode == 'RFND') {
        final String rfnd = '********REFUND********';
        PrintKPFooter += "${textPrintFormat("N", "L", "2")}$RcptNo\n";
      }
    }

    PrintKPAll += PrintKPHdr;
    PrintKPAll += PrintKPItem;
    PrintKPAll += PrintKPFooter;

    return PrintKPAll;
  }

  @override
  Future<List<List<String>>> getKPIndividualItems(
      int salesNo,
      int splitNo,
      int kpNo,
      String tableNo,
      String categoryName,
      String tableName,
      String kpTableName,
      int transID) async {
    final Database dbHandler = await dbHelper.database;
    String addquery = '', addquery2 = '';
    int tblHold = 0;
    if (tableName == 'temp_ReprintKitchen') {
      addquery = 'AND (K.Trans_ID = H.Trans_ID)';
      addquery2 = 'AND H.Trans_ID = $transID';
      tblHold = 1;
    }

    final String query =
        "SELECT H.PLUNo, H.ItemName, H.ItemName_Chinese, H.Quantity, H.ItemSeqNo, H.Preparation, H.TransStatus, PLU.IndividualPrint, H.SalesNo, H.SalesRef, H.PLUSalesRef, H.SplitNo, H.TableNo, H.ItemAmount, SalesCategory.CategoryName, GroupName, DepartmentName FROM $kpTableName K INNER JOIN $tableName H ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) $addquery INNER JOIN PLU ON (H.PLUNo = PLU.PluNumber) INNER JOIN SalesCategory ON (H.CategoryId = SalesCategory.CategoryId) INNER JOIN Departments ON Departments.DepartmentNo = PLU.Department INNER JOIN [Group] ON Departments.GroupNo = [Group].GroupNo WHERE K.SalesNo = $salesNo AND K.SplitNo = $splitNo AND K.PrintToKp = 1 AND K.KPNo = $kpNo AND (H.TransStatus = ' ' OR H.TransStatus = 'M') AND H.SeatNo = 0 AND FunctionId <> 33 AND PLU.IndividualPrint = 1 AND (H.PromotionType <> 'COUPONS' OR H.PromotionType IS NULL) $addquery2 GROUP BY SalesCategory.CategoryName, H.PLUNo, H.ItemName, H.ItemName_Chinese, H.Quantity, H.ItemSeqNo, H.Preparation, H.TransStatus, H.PLUSalesRef, PLU.IndividualPrint, H.SalesNo, H.SalesRef, H.PLUSalesRef, H.SplitNo, H.TableNo, H.ItemAmount, GroupName, DepartmentName ORDER BY SalesCategory.CategoryName, H.PLUSalesRef, H.ItemSeqNo";

    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<List<List<String>>> getKPNo(
      int salesNo,
      int splitNo,
      String categoryName,
      String tableName,
      String kpTableName,
      int transID) async {
    final Database dbHandler = await dbHelper.database;
    String addquery = '', addquery2 = '';
    if (tableName == 'temp_ReprintKitchen') {
      addquery = 'AND (K.Trans_ID = H.Trans_ID)';
      addquery2 = 'AND H.Trans_ID = $transID';
    }

    String query =
        "SELECT DISTINCT KPNo FROM $kpTableName K INNER JOIN $tableName H ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) $addquery INNER JOIN SalesCategory ON (H.CategoryId = SalesCategory.CategoryId) WHERE H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND K.PrintToKp = 1 AND (H.TransStatus = ' ' OR H.TransStatus = 'M') AND ItemName <> 'FOC ITEM' AND (H.PromotionType <> 'COUPONS' OR H.PromotionType IS NULL) AND SalesCategory.CategoryName = '$categoryName' $addquery2 ORDER BY KPNo";
    List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<List<List<String>>> getKPSalesCategory(int salesNo, int splitNo,
      String tableName, String kpTableName, int transID) async {
    final Database dbHandler = await dbHelper.database;

    String addquery = '', addquery2 = '';
    if (tableName == 'temp_ReprintKitchen') {
      addquery = 'AND (K.Trans_ID = H.Trans_ID)';
      addquery2 = 'AND H.Trans_ID = $transID';
    }

    final String query =
        "SELECT DISTINCT SalesCategory.CategoryName, SalesCategory.CategoryID FROM $kpTableName K INNER JOIN $tableName H ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) $addquery INNER JOIN SalesCategory ON (H.CategoryId = SalesCategory.CategoryID) WHERE H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND K.PrintToKp = 1 AND (H.TransStatus = ' ' OR H.TransStatus = 'M') AND H.ItemName <> 'FOC ITEM' AND (H.PromotionType <> 'COUPONS' OR H.PromotionType IS NULL) $addquery2 ORDER BY SalesCategory.CategoryName";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<void> kpPrinting(int kpsNo, int kpsPlNo, String kpTblNo,
      String tblName, String kpTblName, int transID, int countReprint) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateKPPrintItem(int salesNo, int splitNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        'UPDATE KPStatus SET PrintToKp = 0 WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    dbHandler.rawQuery(query);
  }

  @override
  Future<List<List<String>>> getPrinterSetting(int printerID) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        'SELECT KPWidth FROM Printers WHERE PrinterID = $printerID';
    final List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    return maps.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<bool> findAutoCheckOp() async {
    final Database dbHandler = await dbHelper.database;
    const String query = 'SELECT AutoCheck FROM Operator';
    final List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    if (maps.isNotEmpty) {
      return dynamicToBool(maps[0].values.first);
    }
    return false;
  }

  @override
  Future<int> getCover(int salesNo, int splitNo) async {
    final Database dbHandler = await dbHelper.database;

    String query =
        'SELECT Covers FROM HeldTables WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    if (data.isEmpty) {
      query =
          'SELECT Covers FROM SalesTblsTemp WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
      data = await dbHandler.rawQuery(query);
    }

    if (data.isNotEmpty) {
      return dynamicToInt(data[0].values.elementAt(0));
    }
    return 0;
  }

  @override
  Future<String> getRcptNo(int salesNo, int splitNo) async {
    final Database dbHandler = await dbHelper.database;

    String query =
        'SELECT RcptNo FROM HeldTables WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    if (data.isEmpty) {
      query =
          'SELECT RcptNo FROM SalesTblsTemp WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
      data = await dbHandler.rawQuery(query);
    }

    if (data.isNotEmpty) {
      return data[0].values.elementAt(0).toString();
    }
    return '';
  }

  @override
  Future<String> getRemarks(int salesNo, int splitNo, String tableName) async {
    final Database dbHandler = await dbHelper.database;
    String query =
        'SELECT RcptNo FROM HeldTables WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    if (data.isNotEmpty) {
      query =
          'SELECT Remarks FROM HeldTables WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
      data = await dbHandler.rawQuery(query);
    } else {
      query =
          'SELECT Remarks FROM SalesTblsTemp WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
      data = await dbHandler.rawQuery(query);
    }

    if (data.isNotEmpty) {
      final Map<String, dynamic> temp = data[0];
      return temp.values.first.toString();
    }
    return '';
  }

  @override
  Future<List<String>> getKPPrintItems(
      int salesNo,
      int splitNo,
      int kpNo,
      String tableNo,
      String categoryName,
      String tableName,
      String kpTableName,
      int transID) async {
    final Database dbHandler = await dbHelper.database;

    String addquery = '', addquery2 = "", query = "";
    int tblHold = 0;
    final List<String> NewDataArr = <String>[];

    if (tableName == "temp_ReprintKitchen") {
      addquery = "AND (K.Trans_ID = H.Trans_ID)";
      addquery2 = "AND H.Trans_ID = $transID";
      tblHold = 1;
      query =
          "SELECT H.PLUNo, H.ItemName, H.ItemName_Chinese, (H.Quantity) AS qty, H.Preparation, H.TransStatus, H.PLUSalesRef, H.SalesRef, H.ItemSeqNo, H.comments, H.ItemAmount, H.SetMenu, H.SetMenuRef, H.LnkTo, SalesCategory.CategoryName, GroupName, DepartmentName FROM $kpTableName K INNER JOIN $tableName H ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) $addquery INNER JOIN PLU ON (H.PluNo = PLU.PluNumber) INNER JOIN SalesCategory ON (H.CategoryId = SalesCategory.CategoryId) INNER JOIN Departments ON Departments.DepartmentNo = PLU.Department INNER JOIN [Group] ON Departments.GroupNo=[Group].GroupNo WHERE K.SalesNo = $salesNo AND K.SplitNo = $splitNo AND K.PrintToKp = 1 AND K.KPNo = $kpNo AND (H.TransStatus = ' ' OR H.TransStatus = 'M') AND H.SeatNo = 0 AND FunctionId <> 33 AND ItemName <> 'FOC Item' AND (H.PromotionType <> 'COUPONS' OR H.PromotionType IS NULL) $addquery2 GROUP BY SalesCategory.CategoryName, H.PLUNo, H.ItemName, H.ItemName_Chinese, H.Quantity, H.ItemSeqNo, H.Preparation, H.TransStatus, H.PLUsalesref, H.SalesNo, H.SalesRef, H.PLUSalesRef, H.SplitNo, H.TableNo, H.ItemAmount, GroupName, DepartmentName ORDER BY SalesCategory.CategoryName, H.PLUSalesRef, H.ItemSeqNo";
    } else {
      tblHold = 1;
      query =
          "SELECT a.PLUNo, a.ItemName, a.ItemName_Chinese, a.Qty, a.Preparation, a.TransStatus, a.PLUSalesRef, a.SalesRef, a.ItemSeqNo, a.comments, a.ItemAmount, a.SetMenu, a.SetMenuRef, a.LnkTo, GroupName, DepartmentName FROM (SELECT H.PLUNo, H.ItemName, H.ItemName_Chinese, SUM(H.Quantity) AS Qty, H.Preparation, H.TransStatus, H.PLUSalesRef, H.SalesRef, H.ItemSeqNo, H.SalesNo, H.SplitNo, H.TableNo, IFNULL(H.comments,0) AS comments, H.ItemAmount, SetMenu, SetMenuRef, H.LnkTo FROM $kpTableName K INNER JOIN $tableName H ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) $addquery INNER JOIN SalesCategory ON (H.CategoryId = SalesCategory.CategoryId) WHERE H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND K.KPNo = $kpNo AND K.PrintToKp = 1 $addquery2 AND (H.TransStatus = ' ' OR H.TransStatus = 'M') AND H.SeatNo = 0 AND ItemName <> 'FOC Item' and (H.PromotionType <> 'COUPONS' OR H.PromotionType IS NULL) AND SalesCategory.CategoryName = '$categoryName' GROUP BY H.PLUNo, H.ItemName, H.ItemName_Chinese, H.ItemSeqNo, H.Preparation, H.TransStatus, H.PLUSalesRef, H.SalesRef, H.SalesNo, H.SplitNo, H.TableNo, H.comments, H.ItemAmount, SetMenuRef) a LEFT JOIN $tableName HI ON HI.SalesRef = a.PLUSalesRef LEFT JOIN PLU ON PLU.PLUNumber = HI.PLUNo LEFT JOIN Departments ON Departments.DepartmentNo = PLU.Department LEFT JOIN [Group] ON Departments.GroupNo = [Group].GroupNo ORDER BY a.PLUSalesRef,a.ItemSeqNo";
    }

    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    List<String> tempChildArr = <String>[],
        tempParentArr = <String>[],
        tempModArr = <String>[];

    List<List<String>> DataQty;
    String ItemName = '',
        PLUNo = '',
        ItemNameSetMenu = '',
        TransStatus = '',
        LinkTo = '';
    int SalesRef = 0, SetMenuRef = 0, PLUSalesRef = 0;
    bool Prep, SetMenu;
    double Qty;

    for (int i = 0; i < data.length; i++) {
      final Map<String, dynamic> temp = data[i];

      PLUNo = temp.values.elementAt(0).toString();
      ItemName = temp.values.elementAt(1).toString();
      TransStatus = temp.values.elementAt(5).toString();
      PLUSalesRef = dynamicToInt(temp.values.elementAt(6));
      SalesRef = dynamicToInt(temp.values.elementAt(7));
      SetMenuRef = dynamicToInt(temp.values.elementAt(12));
      Prep = dynamicToBool(temp.values.elementAt(4));
      SetMenu = dynamicToBool(temp.values.elementAt(11));
      LinkTo = temp.values.elementAt(13).toString();

      if (TransStatus == 'V') {
        if (tableName == "temp_ReprintKitchen" && (Prep || SetMenu)) {
          query =
              "SELECT PLUNo, ItemName, LnkTo, TransStatus, K.KPNo FROM $kpTableName K INNER JOIN $tableName H ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) $addquery WHERE H.SalesRef = $SetMenuRef $addquery2";
          final List<Map<String, dynamic>> ParentArray =
              await dbHandler.rawQuery(query);

          if (ParentArray.isNotEmpty) {
            final String PLUNoParent =
                ParentArray[0].values.elementAt(0).toString();
            ItemNameSetMenu = ParentArray[0].values.elementAt(1).toString();
            final String LnkToParent =
                ParentArray[0].values.elementAt(2).toString();
            final String TransStatusParent =
                ParentArray[0].values.elementAt(3).toString();
            final int KPNoParent =
                dynamicToInt(ParentArray[0].values.elementAt(4));

            if (LnkToParent == "S" && KPNoParent != kpNo) {
              query =
                  "SELECT SUM(Quantity) FROM $tableName H INNER JOIN SalesCategory ON H.CategoryID = SalesCategory.CategoryID INNER JOIN $kpTableName K ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) WHERE TableNo = '$tableNo' AND H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND PLUNo = '$PLUNoParent' AND TransStatus = '$TransStatusParent' AND K.PrintToKp = $tblHold AND ItemName = \"$ItemNameSetMenu\" AND SalesCategory.CategoryName = '$categoryName' AND SetMenuRef = 0 $addquery2";
              final List<Map<String, dynamic>> tempData =
                  await dbHandler.rawQuery(query);
              DataQty = tempData.map((Map<String, dynamic> e) {
                return e.values.map((dynamic v) => v.toString()).toList();
              }).toList();

              if (DataQty.isNotEmpty) {
                Qty = DataQty[0][0].toDouble();
              } else {
                Qty = 0;
              }

              if (!NewDataArr.contains(ItemNameSetMenu)) {
                NewDataArr.add(Qty.toString());
                NewDataArr.add(ItemNameSetMenu);
              }
            }

            query =
                "SELECT SUM(Quantity) FROM $tableName H INNER JOIN SalesCategory ON H.CategoryID = SalesCategory.CategoryID INNER JOIN $kpTableName K ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) WHERE TableNo = '$tableNo ' AND H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND PLUNo = '$PLUNo' AND TransStatus = '$TransStatus' AND K.PrintToKp = $tblHold AND ItemName = \"$ItemName\" AND SalesCategory.CategoryName = '$categoryName' $addquery2 AND SetMenuRef IN (SELECT SalesRef FROM $tableName WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TransStatus = '$TransStatus' AND TblHold = $tblHold $addquery2 AND PLUNo IN (SELECT PLUNo FROM $tableName WHERE SalesRef = $SetMenuRef $addquery2))";
            final List<Map<String, dynamic>> tempData =
                await dbHandler.rawQuery(query);
            DataQty = tempData.map((Map<String, dynamic> e) {
              return e.values.map((dynamic v) => v.toString()).toList();
            }).toList();
            if (DataQty.isNotEmpty) {
              Qty = DataQty[0][0].toDouble();
            } else {
              Qty = 0;
            }
            final String AllPLU =
                "Parent : " + PLUNoParent + ", Child : " + PLUNo;

            if (!tempChildArr.contains(AllPLU)) {
              NewDataArr.add(Qty.toString());
              NewDataArr.add(ItemName);

              tempChildArr.add(AllPLU);
            }
          } else {
            query =
                "SELECT SUM(Quantity) FROM $tableName H INNER JOIN SalesCategory ON H.CategoryID = SalesCategory.CategoryID INNER JOIN $kpTableName K ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) WHERE TableNo = '$tableNo' AND H.SalesNo = $salesNo AND H.SplitNo = $splitNo  AND PLUNo = '$PLUNo' AND TransStatus = '$TransStatus' AND K.PrintToKp = $tblHold AND ItemName = \"$ItemName\" AND SalesCategory.CategoryName = '$categoryName' $addquery2";
            final List<Map<String, dynamic>> tempData =
                await dbHandler.rawQuery(query);
            DataQty = tempData.map((Map<String, dynamic> e) {
              return e.values.map((dynamic v) => v.toString()).toList();
            }).toList();
            if (DataQty.isNotEmpty) {
              Qty = DataQty[0][0].toDouble();
            } else {
              Qty = 0;
            }

            if (!NewDataArr.contains(ItemName)) {
              NewDataArr.add(Qty.toString());
              NewDataArr.add(ItemName);
            }
          }
        }
      } else {
        query =
            "SELECT PLUNo, ItemName, LnkTo, TransStatus, K.KPNo FROM $kpTableName K INNER JOIN $tableName H ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) $addquery WHERE H.SalesRef = $SalesRef $addquery2";

        final List<Map<String, dynamic>> tempData =
            await dbHandler.rawQuery(query);
        final List<List<String>> ParentArr =
            tempData.map((Map<String, dynamic> e) {
          return e.values.map((dynamic v) => v.toString()).toList();
        }).toList();
        if (ParentArr.isNotEmpty) {
          final String PLUNoParent = ParentArr[0][0];
          ItemNameSetMenu = ParentArr[0][1];
          final String LnkToParent = ParentArr[0][2];
          final String TransStatusParent = ParentArr[0][3];
          final int KPNoParent = ParentArr[0][4].toInt();

          if (LnkToParent == 'S' && KPNoParent != kpNo) {
            query =
                "SELECT SUM(Quantity) FROM $tableName H INNER JOIN SalesCategory ON H.CategoryID = SalesCategory.CategoryID INNER JOIN $kpTableName K ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) WHERE TableNo = '$tableNo' AND H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND PLUNo = '$PLUNoParent' AND TransStatus = '$TransStatusParent' AND K.PrintToKp = $tblHold AND ItemName = \"$ItemNameSetMenu\" AND SalesCategory.CategoryName = '$categoryName' AND SetMenuRef = 0 $addquery2";

            final List<Map<String, dynamic>> tempData =
                await dbHandler.rawQuery(query);
            DataQty = tempData.map((Map<String, dynamic> e) {
              return e.values.map((dynamic v) => v.toString()).toList();
            }).toList();
            if (DataQty.isNotEmpty) {
              Qty = DataQty[0][0].toDouble();
            } else {
              Qty = 0;
            }

            if (!tempParentArr.contains(ItemNameSetMenu)) {
              NewDataArr.add(Qty.toString());
              NewDataArr.add(ItemNameSetMenu);
              tempParentArr.add(ItemNameSetMenu);
            }
          }
          query =
              "SELECT SUM(Quantity) FROM $tableName H INNER JOIN SalesCategory ON H.CategoryID = SalesCategory.CategoryID INNER JOIN $kpTableName K ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) WHERE TableNo = '$tableNo' AND H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND PLUNo = '$PLUNo' AND TransStatus = '$TransStatus' AND K.PrintToKp = $tblHold AND ItemName = \"$ItemName\" AND SalesCategory.CategoryName = '$categoryName' $addquery2 AND SetMenuRef IN (SELECT SalesRef FROM $tableName H INNER JOIN $kpTableName K ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) WHERE H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND K.PrintToKp = $tblHold AND TransStatus = '$TransStatus' $addquery2 AND PLUNo IN (SELECT PLUNo FROM $tableName WHERE SalesRef = $SetMenuRef $addquery2))";
          DataQty = mapListToString2D(await dbHandler.rawQuery(query));

          if (DataQty.isNotEmpty) {
            Qty = DataQty[0][0].toDouble();
          } else {
            Qty = 0;
          }
          final String AllPLU =
              "Parent : " + PLUNoParent + ', Child : ' + PLUNo;

          if (!tempChildArr.contains(AllPLU)) {
            NewDataArr.add(Qty.toString());
            NewDataArr.add(ItemName);
            tempChildArr.add(AllPLU);
          }
        } else {
          if (TransStatus == 'M') {
            query =
                "SELECT PLUNo, ItemName FROM $tableName H WHERE SalesRef = $PLUSalesRef $addquery2";
          } else {
            query =
                "SELECT PLUNo, ItemName FROM $tableName H WHERE SetMenuRef = $SalesRef OR PLUSalesRef = $SalesRef AND SalesRef <> PLUSalesRef AND FunctionID NOT IN (24,25) $addquery2";
          }

          final List<List<String>> ChildArr =
              mapListToString2D(await dbHandler.rawQuery(query));
          String PLUNoChild = "", ItemNameChild = "";

          if (ChildArr.isNotEmpty && TransStatus != "M") {
            if (LinkTo == "S") {
              query =
                  "SELECT SUM(Quantity) FROM $tableName H INNER JOIN SalesCategory ON H.CategoryID = SalesCategory.CategoryID INNER JOIN $kpTableName K ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) WHERE TableNo = '$tableNo' AND H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND PLUNo = '$PLUNo' AND TransStatus = '$TransStatus' AND K.PrintToKp = $tblHold AND ItemName = \"$ItemName\" AND SalesCategory.CategoryName = '$categoryName' AND SetMenuRef = 0 $addquery2 AND SalesRef IN (SELECT SetMenuRef FROM $tableName H INNER JOIN $kpTableName K ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) WHERE H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND TransStatus = '$TransStatus' AND K.PrintToKp = $tblHold $addquery2 AND PLUNo IN (SELECT PLUNo FROM $tableName WHERE SetMenuRef = $SalesRef OR PLUSalesRef = $SalesRef AND SalesRef <> PLUSalesRef $addquery2))";
            } else {
              query =
                  "SELECT SUM(Quantity) FROM $tableName H INNER JOIN SalesCategory ON H.CategoryID = SalesCategory.CategoryID INNER JOIN $kpTableName K ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) WHERE TableNo = '$tableNo' AND H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND PLUNo = '$PLUNo' AND TransStatus = '$TransStatus' AND K.PrintToKp = $tblHold AND ItemName = \"$ItemName\" AND SalesCategory.CategoryName = '$categoryName' AND SetMenuRef = 0 $addquery2 AND SalesRef IN (SELECT PLUSalesRef FROM $tableName H INNER JOIN $kpTableName K ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) WHERE H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND K.PrintToKp = $tblHold $addquery2 AND ItemName IN (SELECT ItemName FROM $tableName WHERE SetMenuRef = $SalesRef OR PLUSalesRef = $SalesRef AND SalesRef <> PLUSalesRef $addquery2))";
            }
          } else {
            query =
                "SELECT SUM(Quantity) FROM $tableName H INNER JOIN SalesCategory ON H.CategoryID = SalesCategory.CategoryID INNER JOIN $kpTableName K ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) WHERE TableNo = '$tableNo' AND H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND PLUNo = '$PLUNo' AND TransStatus = '$TransStatus' AND K.PrintToKp = $tblHold AND ItemName = \"$ItemName\" AND SalesCategory.CategoryName = '$categoryName' AND SetMenuRef = 0 $addquery2 AND SalesRef NOT IN (SELECT PLUSalesRef FROM $tableName H INNER JOIN $kpTableName K ON (K.SalesNo = H.SalesNo) AND (K.SplitNo = H.SplitNo) AND (K.ItemSeqNo = H.ItemSeqNo) WHERE H.SalesNo = $salesNo AND H.SplitNo = $splitNo AND K.PrintToKp = $tblHold AND SalesRef <> PLUSalesRef $addquery2)";
          }
          DataQty = mapListToString2D(await dbHandler.rawQuery(query));

          if (DataQty.isNotEmpty) {
            Qty = DataQty[0][0].toDouble();
          } else {
            Qty = 0;
          }

          String AllPLU = "", AllPLUMod = "";

          if (TransStatus == "M") {
            PLUNoChild = ChildArr[0][0];
            ItemNameChild = ChildArr[0][1];
            AllPLUMod = "Parent : " + ItemNameChild + ", Child : " + ItemName;

            if (!tempModArr.contains(AllPLUMod)) {
              NewDataArr.add(Qty.toString());
              NewDataArr.add(ItemName);
              tempModArr.add(AllPLUMod);
            }
          } else {
            AllPLU = "Parent : " + ItemName + ", Child : " + ItemNameChild;
            if (!tempParentArr.contains(AllPLU)) {
              NewDataArr.add(Qty.toString());
              NewDataArr.add(ItemName);
              tempParentArr.add(AllPLU);
            }
          }
        }
      }
    }

    return NewDataArr;
  }

  @override
  Future<List<List<String>>> generateMasterKP(int masterKPID, String ctgName,
      int ctgID, String tblNo, int salesNo, int splitNo, int masterID) {
    throw UnimplementedError();
  }

  @override
  Future<List<List<String>>> getMasterKPID(String posID) async {
    final Database dbHandler = await dbHelper.database;
    String query =
        "SELECT MasterKPID, MasterKP2ID, MasterKP3ID FROM POSDtls WHERE POSID = '$posID'";
    List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<List<List<String>>> getMasterKPSC(
      int salesNo, int splitNo, int masterKPID, int masterID) async {
    final Database dbHandler = await dbHelper.database;
    String MasterKPPrint = '';
    if (masterID == 1) {
      MasterKPPrint = 'MasterKPPrint';
    } else {
      MasterKPPrint = 'MasterKPPrint $masterID';
    }

    String query =
        "SELECT DISTINCT IFNULL(h.CategoryId,''), IFNULL(CategoryName,'DINE IN') FROM HeldItems h INNER JOIN SalesCategory s ON h.CategoryId = s.CategoryId INNER JOIN PLU ON h.PLUNo = PLU.PLUNumber WHERE SalesNo = $salesNo AND SplitNo = splitNo And masterKPPrint = $masterKPID ORDER BY CategoryName";
    List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }
}
