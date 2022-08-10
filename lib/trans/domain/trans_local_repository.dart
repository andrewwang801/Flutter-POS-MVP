// ignore_for_file: avoid_dynamic_calls

import 'package:injectable/injectable.dart';
import 'package:raptorpos/common/extension/string_extension.dart';
import 'package:raptorpos/trans/data/trans_sales_data_model.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../common/GlobalConfig.dart';
import '../../common/helper/db_helper.dart';
import '../../common/utils/datetime_util.dart';
import '../../common/utils/type_util.dart';
import '../../floor_plan/repository/i_tablemangement_repository.dart';

@Injectable()
class TransLocalRepository with TypeUtil, DateTimeUtil {
  TransLocalRepository(this.dbHelper, this.tableRepository);

  final LocalDBHelper dbHelper;
  final ITableMangementRepository tableRepository;

  Future<List<TransSalesData>> getOpenSalesData(
      String date1, String date2, String time1, String time2) async {
    final Database db = await dbHelper.database;
    String query =
        "SELECT RcptNo, TableNo, OperatorName, IFNULL(GTotal, 0) AS GTotal, Open_Date, Open_Time, IFNULL(Close_Date, '') AS Close_Date, IFNULL(Close_Time, '') AS Close_Time, TransMode, POSID, SalesNo, SplitNo, Covers, IFNULL(TransStatus, '') AS TransStatus FROM HeldTables INNER JOIN Operator ON HeldTables.OperatorNo = Operator.OperatorNo WHERE (Open_Date || ' ' || Open_Time) >= '$date1 $time1' AND (Open_Date || ' ' || Open_Time) <= '$date2 $time2' ORDER BY Open_Date DESC, Open_Time DESC";
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) => TransSalesData.fromJson(e)).toList();
  }

  Future<List<TransSalesData>> getCloseSalesData(
      String date1, String date2, String time1, String time2) async {
    final Database db = await dbHelper.database;
    String query =
        "SELECT RcptNo, TableNo, OperatorName, IFNULL(GTotal, 0) AS GTotal, Open_Date, Open_Time, IFNULL(Close_Date, '') AS Close_Date, IFNULL(Close_Time, '') AS Close_Time, TransMode, POSID, SalesNo, SplitNo, Covers, IFNULL(TransStatus, '') AS TransStatus FROM SalesTblsTemp INNER JOIN Operator ON SalesTblsTemp.OperatorNo = Operator.OperatorNo WHERE (Open_Date || ' ' || Open_Time) >= '$date1 $time1' AND (Open_Date || ' ' || Open_Time) <= '$date2 $time2' ORDER BY Open_Date DESC, Open_Time DESC";

    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) => TransSalesData.fromJson(e)).toList();
  }

  Future<void> checkRefundFunction(int salesNo, int splitNo, String salesAreaID,
      String posID, String rcptNo) async {
    String sDate = currentDateTime('yyyy-MM-dd');
    String sTime = currentDateTime('HH:mm:ss');

    final String query =
        "SELECT ZdayReportDt, ZdayReportTime FROM POSDtls WHERE POSID = '$posID'";

    final Database db = await dbHelper.database;
    List<Map<String, dynamic>> maps = await db.rawQuery(query);

    if (maps.isEmpty) {
      throw OperationFailedException('Refund failed!', 'No item to refund');
    }
    String zDayReportDt = maps[0].values.elementAt(0).toString();
    zDayReportDt = zDayReportDt.substring(0, 10);
    String zDayReportTime = maps[0].values.elementAt(1).toString();
    zDayReportTime = zDayReportDt.substring(11);

    String newZDay = '$zDayReportDt $zDayReportTime';
    DateTime zDay = DateTime.parse(newZDay);

    String newDate = '$sDate $sTime';
    DateTime dateNow = DateTime.parse(newDate);

    if (dateNow.compareTo(zDay) < 0) {
      throw OperationFailedException('Refund Failed!',
          'You can not d a refund after Z day sales, do not try to backdate');
    } else {
      final String query =
          'SELECT COUNT(SalesNo), RfndRcptNo FROM AutoRfndBill WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
      maps = await db.rawQuery(query);
      if (maps.isNotEmpty && dynamicToInt(maps[0].values.elementAt(0)) > 0) {
        throw OperationFailedException('Refund Failed!',
            'ReceiptNo $rcptNo had been refunded with ReceptNo ${maps[0].values.elementAt(1)}');
      } else {
        final String query =
            'SELECT TransMode, TransStatus FROM SalesTblsTemp WHERE SalesNo = $salesNo AND SplitNo =$splitNo';

        maps = await db.rawQuery(query);

        if (maps.isEmpty) {
          throw OperationFailedException(
              'Refund Failed!', 'Can not refund open table.');
        } else {
          final String transMode = maps[0].get(0).toString();
          if (transMode == 'RFND') {
            throw OperationFailedException(
                'Refund Failed!', 'TransMode is already Refund');
          } else {
            String transStatus = maps[0].get(1).toString();
            if (transStatus != ' ' && transStatus != 'H') {
              throw OperationFailedException(
                  'Refund Failed!', 'TransStatus can not be refunded');
            } else {
              final String query =
                  "SELECT COUNT(SalesNo) FROM SalesItemsTemp WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TransStatus = ' ' AND ItemSeqNo = 101 AND SubFunctionID <> 0 AND SubFunctionID NOT IN (SELECT SubFunctionID FROM Media WHERE FunctionID IN (1,2) OR (FunctionID = 4 AND IFNULL(Voucher,0) > 0) OR (FunctionID = 6 AND IFNULL(Verifyroom3,0) = 1))";

              maps = await db.rawQuery(query);
              if (maps.isNotEmpty && dynamicToInt(maps[0].get(0)) > 0) {
                throw OperationFailedException('Refund Failed!',
                    'Auto Refund can only served CASH / CARD / CPR Coucher Payment / IQDynamic Room Charge Method');
              }
            }
          }
        }
      }
    }
  }

  Future<List<List<String>>> getRefundTypes() async {
    const String query = 'SELECT * FROM RefundTypes ORDER BY RefundID';
    final Database db = await dbHelper.database;
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<void> doRefundFunction(int salesNo, int splitNo, int operatorNo,
      int rfndID, String rcptNo) async {
    String sDate = currentDateTime('yyyy-MM-dd');
    String sTime = currentDateTime('HH:mm:ss');

    int sNo = await tableRepository.nextSalesNumber();
    if (sNo == 0) {
      throw OperationFailedException(
          'Refund Error', 'Generate Sales Number Failed. Please try again');
    }
    final Database db = await dbHelper.database;
    String query =
        'SELECT POSID, SalesNo, SplitNo, TableNo, Covers, STotal, GTotal, PaidAmount, Balance, SalesAreaID FROM SalesTblsTemp WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);

    if (maps.isEmpty) {
      throw OperationFailedException(
          'Refund Error', 'Not found from SalesTblsTemp');
    }
    int rfndSNo = dynamicToInt(maps[0].get(1));
    int rfndSplNo = dynamicToInt(maps[0].get(2));
    final String rcpt = await tableRepository.nextReceiptNumber();
    final String rfndTblNo = maps[0].get(3).toString();
    final int rfndCover = dynamicToInt(maps[0].get(4));
    final double rfndSTotal = dynamicToDouble(maps[0].get(5));
    final double rfndGTotal = dynamicToDouble(maps[0].get(6));
    final double rfndPaid = dynamicToDouble(maps[0].get(7));
    final double rfndBalance = dynamicToDouble(maps[0].get(8));
    final double rfndSalesArea = dynamicToDouble(maps[0].get(9));

    query =
        "INSERT INTO SalesTblsTemp (SalesNo, SplitNo, POSID, TableNo, OperatorNo, Open_Date, Open_Time, TransMode, Covers, RcptNo, Operatornofirst, STotal, GTotal, PaidAmount, Balance, SalesAreaID, Close_Date, Close_Time, BusinessDate) VALUES ($sNo, $splitNo, '${POSDtls.deviceNo}', '$rfndTblNo', $operatorNo, '$sDate', '$sTime', 'RFND',  $rfndCover, '$rcpt', $operatorNo, $rfndSTotal, $rfndGTotal, $rfndPaid, $rfndBalance, '$rfndSalesArea', '$sDate', '$sTime', '${POSDefault.StrBusinessDate}')";
    await db.rawQuery(query);
    query =
        "INSERT INTO SalesItemsTemp (POSID, OperatorNo, Covers, PLUNo, Department, SDate, STime, Quantity, ItemName, ItemName_Chinese, ItemAmount, PaidAmount, ChangeAmount, Gratuity, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, Adjustment, DiscountType, DiscountPercent, Discount, PromotionId, PromotionType, PromotionSaving, TransMode, RefundID, TransStatus, FunctionID, SubFunctionID, MembershipID, LoyaltyCardNo, CustomerID, CardScheme, CreditCardNo, AvgCost, RecipeId, PriceShift, CategoryId, TransferredOp, KitchenPrint1, KitchenPrint2, KitchenPrint3, RedemptionItem, PointsRedeemed, ShiftID, PrintFreePrep, PrintPrepWithPrice, Preparation, FOCItem, FOCType, ApplyTax0, ApplyTax1, ApplyTax2, ApplyTax3, ApplyTax4, ApplyTax5, ApplyTax6, ApplyTax7, ApplyTax8, ApplyTax9, LnkTo, BuyXfreeYapplied, RndingAdjustments, PostSendVoid, TblHold, DepositID, SeatNo, SalesNo, SplitNo, ItemSeqNo, TransferredTable, TableNo, SalesRef, PLUSalesRef, ServerNo, SalesAreaID, SetMenu, SetMenuRef, TaxTag, BusinessDate) SELECT POSID, $operatorNo, Covers, PLUNo, Department, '$sDate', '$sTime', Quantity, ItemName, ItemName_Chinese, ItemAmount, PaidAmount, ChangeAmount, Gratuity, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, Adjustment, DiscountType, DiscountPercent, Discount, PromotionId, PromotionType, PromotionSaving, 'RFND', $rfndID, TransStatus, FunctionID, SubFunctionID, MembershipID, LoyaltyCardNo, CustomerID, CardScheme, CreditCardNo, AvgCost, RecipeId, PriceShift, CategoryId, TransferredOp, KitchenPrint1, KitchenPrint2, KitchenPrint3, RedemptionItem, PointsRedeemed, ShiftID, PrintFreePrep, PrintPrepWithPrice, Preparation, FOCItem, FOCType, ApplyTax0, ApplyTax1, ApplyTax2, ApplyTax3, ApplyTax4, ApplyTax5, ApplyTax6, ApplyTax7, ApplyTax8, ApplyTax9, LnkTo, BuyXfreeYapplied, RndingAdjustments, PostSendVoid, TblHold, DepositID, SeatNo, $sNo, 0, ItemSeqNo, TransferredTable, TableNo, SalesRef, PLUSalesRef, ServerNo, SalesAreaID, SetMenu, SetMenuRef, TaxTag, '${POSDefault.StrBusinessDate}' FROM SalesItemsTemp Where SalesNo = $rfndSNo AND SplitNo = $rfndSplNo";
    await db.rawQuery(query);
    query =
        "INSERT INTO AutoRfndBill VALUES ('$rcptNo', '$rcpt', $rfndSNo, $rfndSplNo, $sNo, $splitNo)";
    await db.rawQuery(query);
    query =
        "INSERT INTO RcptDtls (ReceiptNo, OperatorNo, TableNo, SplitNo, SalesNo, Finalized, Printed, Void, TaxExempt, CopyNo, SalesAreaID, BusinessDate) VALUES ('$rcpt', $operatorNo, '$rfndTblNo', $splitNo, $sNo, 1, 0, 0, 0, 0, '$rfndSalesArea ', '${POSDefault.StrBusinessDate}')";
    await db.rawQuery(query);
  }

  Future<List<List<String>>> getDataSales(
      int salesNo, int splitNo, String tableNo, String tableStatus) async {
    String query = '';
    if (tableStatus == 'Close Tables') {
      query =
          "SELECT Quantity, ItemName, IFNULL(ItemAmount,0.00), IFNULL(DiscountType,''), IFNULL(Discount,0.00), OperatorName, TransMode, TransStatus, IFNULL(SubFunctionID,0), TableNo, IFNULL(Covers,1), POSID, FunctionID, ItemSeqNo, SalesRef FROM SalesItemsTemp INNER JOIN Operator ON SalesItemsTemp.OperatorNo = Operator.OperatorNo WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo' AND TransStatus = ' ' ORDER BY SalesRef, ItemSeqNo";
    } else {
      query =
          "SELECT Quantity, ItemName, IFNULL(ItemAmount,0.00), IFNULL(DiscountType,''), IFNULL(Discount,0.00), OperatorName, TransMode, TransStatus, IFNULL(SubFunctionID,0), TableNo, IFNULL(Covers,1), POSID, FunctionID, ItemSeqNo, SalesRef FROM HeldItems INNER JOIN Operator ON HeldItems.OperatorNo = Operator.OperatorNo WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo' AND TransStatus = ' ' ORDER BY SalesRef, ItemSeqNo";
    }
    final Database db = await dbHelper.database;
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<List<List<String>>> getMediaData() async {
    final String query =
        "SELECT Title, FunctionID, SubFunctionID, TenderValue, Maximum FROM Media WHERE FunctionID IN (1,2,4,7) AND MActive = 1 ORDER BY FunctionID, Title";

    final Database db = await dbHelper.database;
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<List<List<String>>> getMediaByType(int funcId) async {
    final String query =
        "SELECT Title, FunctionID, SubFunctionID, TenderValue, Maximum FROM Media WHERE FunctionID = $funcId AND MActive = 1 ORDER BY FunctionID, Title";

    final Database db = await dbHelper.database;
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<List<List<String>>> getMediaType() async {
    final String query =
        "SELECT FunctionId, Type FROM Functions WHERE FunctionId IN (1, 2, 4, 7)";

    final Database db = await dbHelper.database;
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<void> billAdjustFunction(
      String mediaName,
      int funcId,
      int subFuncId,
      int salesNo,
      int splitNo,
      int salesRef,
      String fMedia,
      String rcptNo,
      double itemAmount) async {
    final Database db = await dbHelper.database;
    String query =
        "UPDATE SalesItemsTemp SET ItemName = '$mediaName', FunctionID = $funcId, SubFunctionID = $subFuncId WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND SalesRef = $salesRef";
    await db.rawQuery(query);

    String sDate = currentDateTime('yyyy-MM-dd');
    String sTime = currentDateTime('HH:mm:ss');

    query =
        "INSERT INTO BillAdjustments (FMedia, TMedia, ReceiptNo, ItemAmount, POSID, OperatorNo, SDate, STime) VALUES ('$fMedia', '$mediaName', '$rcptNo', $itemAmount, '${POSDtls.deviceNo}', ${GlobalConfig.operatorNo}, '$sDate', '$sTime')";
    await db.rawQuery(query);

    query =
        "UPDATE SalesTblsTemp SET SendFlag = 0 WHERE SalesNo = $salesNo AND SplitNo = $splitNo";
    await db.rawQuery(query);
  }

  Future<List<String>> doReprintKitchenFunction(int salesNo, int splitNo,
      int operatorNo, List<String> sRefArray, List<String> iSeqNoArray) async {
    final Database db = await dbHelper.database;
    String query =
        'SELECT COUNT(*) FROM tbl_ReprintKitchenLog WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    List<Map<String, dynamic>> data = await db.rawQuery(query);
    int count = 0;
    if (data.isNotEmpty) {
      count = dynamicToInt(data[0].get(0));
    }

    query = 'SELECT MAX(Trans_ID) FROM tbl_ReprintKitchenLog';
    await db.rawQuery(query);
    int transID = 0;

    if (data.isNotEmpty) {
      transID = dynamicToInt(data[0].get(0));
    }

    transID += 1;
    count += 1;

    String transDate = currentDateTime('yyyy-MM-dd HH:mm:ss.sss');

    query =
        "INSERT INTO tbl_ReprintKitchenLog (Trans_ID, SalesNo, SplitNo, OperatorNo, TransDate) VALUES ($transID, $salesNo, $splitNo, $operatorNo, '$transDate')";
    await db.rawQuery(query);

    query =
        'SELECT RcptNo FROM HeldTables WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    await db.rawQuery(query);
    String tblName = 'SalesItemsTemp', kpTblName = 'CheckKPStatus';

    if (data.isNotEmpty) {
      tblName = 'HeldItems';
      kpTblName = 'KPStatus';
    }

    for (int i = 0; i < sRefArray.length; i++) {
      int sRef = sRefArray[i].toInt();
      int iSeqNo = iSeqNoArray[i].toInt();

      query =
          "INSERT INTO Temp_ReprintKitchen (POSID, OperatorNo, Covers, TableNo, SalesNo, SplitNo, SalesRef, PLUSalesRef, ItemSeqNo, PLUNo, Department, SDate, STime, Quantity, ItemName, ItemName_Chinese, ItemAmount, PaidAmount, ChangeAmount, Discount, PromotionSaving, Gratuity, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, Adjustment, DiscountType, DiscountPercent, Discount, PromotionId, PromotionSaving, TransMode, RefundId, TransStatus, FunctionId, SubFunctionId, MembershipId, LoyaltyCardNo, CustomerId, CardScheme, CreditCardNo, AvgCost, RecipeId, PriceShift, CategoryId, TransferredTable, TransferredOp, KitchenPrint1, KitchenPrint2, KitchenPrint3, RedemptionItem, PointsRedeemed, ShiftId, PrintFreePrep, PrintPrepWithPrice, Preparation, FOCItem, FOCType, ApplyTax0, ApplyTax1, ApplyTax2, ApplyTax3, ApplyTax4, ApplyTax5, ApplyTax6, ApplyTax7, ApplyTax8, ApplyTax9, LnkTo, BuyXFreeYApplied, RndingAdjustments, SetMenu, SetMenuRef, Instruction, PostSendVoid, TblHold, DepositId, TSalesRef, TSalesNo, TSplitNo, RentalItem, RentToDate, RentToTime, MinsRented, SeatNo, SalesAreaId, BusinessDate, ServerNo, OperatorFOC, OperatorNoFirst, cc_promo1, cc_promo2, Voucherseqno, tbl_ServedTime, ServedStatus, comments, Switchid, OperatorPromo, TrackPrep, RentFromTime, PromotionType, Trans_ID) SELECT POSID, OperatorNo, Covers, TableNo, SalesNo, SplitNo, SalesRef, PLUSalesRef, ItemSeqNo, PLUNo, Department, SDate, STime, Quantity, ItemName, ItemName_Chinese, ItemAmount, PaidAmount, ChangeAmount, IFNULL(Discount,0),IFNULL(PromotionSaving,0), Gratuity, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, Adjustment, DiscountType, DiscountPercent, Discount, PromotionId, PromotionSaving, TransMode, RefundId, TransStatus, FunctionId, SubFunctionId, MemberShipId, LoyaltyCardNo, CustomerId, IFNULL(CardScheme,0), IFNULL(CreditCardNo,0), AvgCost, RecipeId, PriceShift, CategoryId, IFNULL(TransferredTable,0), IFNULL(TransferredOp,0), KitchenPrint1, KitchenPrint2, KitchenPrint3, RedemptionItem, PointsRedeemed, ShiftId, PrintFreePrep, PrintPrepWithPrice, Preparation, FOCItem, FOCType, ApplyTax0, ApplyTax1, ApplyTax2, ApplyTax3, ApplyTax4, ApplyTax5, ApplyTax6, ApplyTax7, ApplyTax8, ApplyTax9, LnkTo, BuyXFreeYApplied, RndingAdjustments, SetMenu, SetMenuRef, Instruction, PostSendVoid, TblHold, DepositId, TSalesRef, TSalesNo, TSplitNo, RentalItem, RentToDate, RentToTime, MinsRented, SeatNo, SalesAreaId, BusinessDate, ServerNo, OperatorFOC, OperatorNoFirst, cc_promo1, cc_promo2, Voucherseqno, tbl_ServedTime, ServedStatus, comments, Switchid, OperatorPromo, TrackPrep, RentFromTime, '', $transID FROM $tblName WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND SalesRef = $sRef";
      await db.rawQuery(query);
      query =
          'INSERT INTO tbl_ReprintKPStatus SELECT $transID, SalesNo, SplitNo, ItemSeqNo, KPNo, 1 FROM $kpTblName WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND ItemSeqNo = $iSeqNo';
      await db.rawQuery(query);
    }

    List<String> paramArray;
    tblName = 'temp_ReprintKitchent';
    kpTblName = 'tbl_ReprintKPStatus';

    paramArray = <String>[
      count.toString(),
      transID.toString(),
      tblName,
      kpTblName
    ];

    return paramArray;
  }

  Future<bool> checkOperatorReprint() async {
    final Database db = await dbHelper.database;
    final String query =
        'SELECT opReprintKitchenReceipt FROM Operator WHERE OperatorNo = ${GlobalConfig.operatorNo}';
    List<Map<String, dynamic>> data = await db.rawQuery(query);

    if (data.isNotEmpty) {
      bool opReprintKitchen = dynamicToBool(data[0].get(0));
      return opReprintKitchen;
    }
    return false;
  }

  Future<bool> checkBillAdj() async {
    String sDate = currentDateTime("yyyy-MM-dd");
    String sTime = currentDateTime("HH:mm:ss");

    final Database db = await dbHelper.database;
    String query =
        "SELECT ZDayReportDt, ZDayReportTime FROM POSDtls WHERE POSID = '${POSDtls.deviceNo}'";
    List<Map<String, dynamic>> data = await db.rawQuery(query);

    if (data.isEmpty) {
      throw OperationFailedException('Bill Adj Failed!', '');
    }

    String zDayReportDt = data[0].get(0).toString();
    zDayReportDt = zDayReportDt.substring(0, 10);
    String zDayReportTime = data[0].get(1).toString();
    zDayReportTime = zDayReportTime.substring(11);

    String newZDay = '$zDayReportDt $zDayReportTime';
    DateTime zDay = DateTime.parse(newZDay);

    String newDate = '$sDate $sTime';
    DateTime dateNow = DateTime.parse(newDate);
    bool isBlocked = false;

    if (dateNow.compareTo(zDay) < 0) {
      isBlocked = true;
      throw OperationFailedException('Bill Adj Failed!',
          'You cannot do a bill adjustment after Z Day Sales, do not try to change the date.');
    }

    return isBlocked;
  }

  Future<List<List<String>>> reprintItem(int salesNo, int splitNo) async {
    final Database db = await dbHelper.database;
    String query =
        'SELECT RcptNo FROM HeldTables WHERE SalesNo = $salesNo AND Splitno = $splitNo';
    List<Map<String, dynamic>> data = await db.rawQuery(query);

    String tblName = '', kpTblName = '';

    if (data.isNotEmpty) {
      tblName = 'HeldItems';
      kpTblName = 'KPStatus';
    } else {
      tblName = 'SalesItemsTemp';
      kpTblName = 'CheckKPStatus';
    }

    if (POSDtls.intlanguageop == 1) {
      query =
          "SELECT a.SalesRef, a.ItemSeqNo, a.Quantity, a.ItemName_Chinese, (SELECT COUNT(*) FROM tbl_ReprintKitchenLog WHERE SalesNo = $salesNo AND SplitNo = $splitNo), COUNT(b.ItemSeqNo) FROM $tblName a LEFT JOIN tbl_ReprintKPStatus b ON a.SalesNo = b.SalesNo AND a.SplitNo = b.SplitNo AND a.ItemSeqNo = b.ItemSeqNo WHERE (FunctionID = 26 AND (TransStatus = ' ' OR TransStatus = 'M')) AND a.SalesNo = $salesNo AND a.SplitNo = $splitNo AND a.ItemSeqNo IN (SELECT ItemSeqNo FROM $kpTblName WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PrintToKP = 0) GROUP BY a.SalesRef, a.ItemSeqNo, a.Quantity, a.ItemName";
    } else {
      query =
          "SELECT a.SalesRef, a.ItemSeqNo, a.Quantity, a.ItemName, (SELECT COUNT(*) FROM tbl_ReprintKitchenLog WHERE SalesNo = $salesNo AND SplitNo = $salesNo), COUNT(b.ItemSeqNo) FROM $tblName a LEFT JOIN tbl_ReprintKPStatus b ON a.SalesNo = b.SalesNo AND a.SplitNo = b.SplitNo AND a.ItemSeqNo = b.ItemSeqNo WHERE (FunctionID = 26 AND (TransStatus = ' ' OR TransStatus = 'M')) AND a.SalesNo = $salesNo AND a.SplitNo = $splitNo AND a.ItemSeqNo IN (SELECT ItemSeqNo FROM $kpTblName WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PrintToKP = 0) GROUP BY a.SalesRef, a.ItemSeqNo, a.Quantity, a.ItemName";
    }

    data = await db.rawQuery(query);
    return mapListToString2D(data);
  }
}

class OperationFailedException implements Exception {
  OperationFailedException(this.operationErrMsg, this.errDetailMsg);

  final String operationErrMsg;
  final String errDetailMsg;
}
