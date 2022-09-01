import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../../common/helper/db_helper.dart';
import '../../common/utils/datetime_util.dart';
import '../../common/utils/type_util.dart';

@Injectable()
class ReportLocalRepository with TypeUtil, DateTimeUtil {
  ReportLocalRepository(this.dbHelper);

  final LocalDBHelper dbHelper;

  Future<void> transaction(String date1, String date2, String posID) async {
    final Database dbHandler = await dbHelper.database;
    String query = "DELETE FROM Transactions WHERE DeviceID = '$posID'";
    await dbHandler.rawQuery(query);

    query =
        "INSERT INTO Transactions (DeviceID, OperatorNo, FunctionID, SubFunctionID, Qty, Amount, TipCnt, TipAmnt, RndingAdjCnt, RndingAdjAmnt, DepQty, DepAmount, DepTipCnt, DepTipAmnt, DepChangeCnt, DepChangeAmnt, ForeignPaidAmnt, ForeignChangeAmnt) SELECT '$posID', OperatorNo, FunctionID, SubFunctionID, SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(ItemAmount * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(Gratuity,0) <> 0) THEN 1 ELSE 0 END), SUM(IFNULL(Gratuity,0) * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(Gratuity,0) <> 0) THEN 1 ELSE 0 END), SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(RndingAdjustments,0) <> 0) THEN 1 ELSE 0 END), SUM(IFNULL(RndingAdjustments,0) * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(RndingAdjustments,0) <> 0) THEN 1 ELSE 0 END), SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(DepositID,0) > 0) THEN 1 ELSE 0 END), SUM(ItemAmount * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(DepositID,0) > 0) THEN 1 ELSE 0 END), SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(Gratuity,0) <> 0) THEN 1 ELSE 0 END * CASE WHEN (IFNULL(DepositID,0) > 0) THEN 1 ELSE 0 END), SUM(Gratuity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(Gratuity,0) <> 0) THEN 1 ELSE 0 END * CASE WHEN (IFNULL(DepositID,0) > 0) THEN 1 ELSE 0 END), SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (ChangeAmount <> 0) THEN 1 ELSE 0 END * CASE WHEN (IFNULL(DepositID,0) > 0) THEN 1 ELSE 0 END), SUM(ChangeAmount * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (ChangeAmount <> 0) THEN 1 ELSE 0 END * CASE WHEN (IFNULL(DepositID,0) > 0) THEN 1 ELSE 0 END), SUM(IFNULL(ForeignPaidAmnt,0) * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(IFNULL(ChangeAmount,0) * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * (CASE WHEN (IFNULL(foreignpaidamnt,0) = 0) THEN 0 ELSE 1 END)) FROM SalesItemsTemp WHERE ((SDate || ' ' || STime) >= '$date1') AND ((SDate || ' ' || STime) <= '$date2') AND FunctionID IN (1,2,3,4,5,6,7,8,9) AND TransStatus = ' ' GROUP BY OperatorNo, FunctionID, SubFunctionID";
    await dbHandler.rawQuery(query);

    query =
        'SELECT Media.Title, Media.FunctionID, Media.SubFunctionID FROM Media INNER JOIN Transactions ON (Transactions.SubFunctionID = Media.SubFunctionID) AND (Transactions.FunctionID = Media.FunctionID)';
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    for (int i = 0; i < data.length; i++) {
      final String mTitle = data[i].get(0).toString();
      int mFunc = dynamicToInt(data[i].get(1));
      int mSfunc = dynamicToInt(data[i].get(2));

      query =
          "UPDATE Transactions SET Title = '$mTitle' WHERE SubFunctionID = $mSfunc AND FunctionID = $mFunc";
      await dbHandler.rawQuery(query);
    }

    query =
        "UPDATE Transactions SET Title = 'CASH' WHERE FunctionID = 1 AND SubFunctionID = 0";
    await dbHandler.rawQuery(query);
  }

  Future<void> salesReport(String date1, String date2, String posID) async {
    final Database dbHandler = await dbHelper.database;
    String query = "DELETE FROM SalesReport WHERE DeviceID = '$posID'";
    await dbHandler.rawQuery(query);

    query =
        "INSERT INTO SalesReport (DeviceID, Helditem, Groupname, category, Sold, ItemSales, DiscCnt, Disc, BillDiscCnt, BillDisc, ItemFOCCnt, ItemFOC, BillFOCCnt, BillFOC, RedeemCnt, RedeemPoints, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, BillCount, CoverCount, Void, Refund, VoidCnt, RefundCnt, Surcharge) SELECT '$posID', 0, GroupName, CategoryID, SUM(Quantity * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * ItemAmount * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (IFNULL(PromotionSaving,0) <> 0 OR IFNULL(Discount,0) <> 0) THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (FOCType = 'FOC Item') THEN 0 ELSE 1 END), SUM((IFNULL(Discount,0) + IFNULL(PromotionSaving,0)) * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (FOCType = 'FOC Item') THEN 0 ELSE 1 END), SUM((1) * CASE WHEN (FunctionID = 25) THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(ItemAmount * CASE WHEN (FunctionID = 25) THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (FOCType = 'FOC Item') THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM((Quantity * ItemAmount) * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (FOCType = 'FOC Item') THEN 1 ELSE 0 END), SUM(Quantity * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (FOCType = 'FOC Bill') THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(((Quantity * ItemAmount) - (IFNULL(Discount,0) + IFNULL(PromotionSaving,0))) * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (FOCType = 'FOC Bill') THEN 1 ELSE 0 END), SUM(Quantity * CASE WHEN (FunctionID = 27) THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(ItemAmount * CASE WHEN (FunctionID = 27) THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax0 * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax1 * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax2 * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax3 * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax4 * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax5 * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax6 * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax7 * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax8 * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax9 * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * CASE WHEN (SI.TransStatus = 'S') THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), SUM(SI.Covers * CASE WHEN (SI.TransStatus = 'S') THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END), 0, 0, 0, 0, SUM(ItemAmount * CASE WHEN (FunctionID = 55) THEN 1 ELSE 0 END * CASE WHEN (SI.TransMode = 'REG') THEN 1 ELSE -1 END) FROM SalesItemsTemp SI LEFT JOIN Departments ON DepartmentNo = Department LEFT JOIN [Group] ON [Group].GroupNo = Departments.GroupNo WHERE ((SDate || ' ' || STime) >= '$date1') AND ((SDate || ' ' || STime) <= '$date2') AND (SI.TransStatus = ' ' OR SI.TransStatus = 'S') GROUP BY GroupName, CategoryID";
    await dbHandler.rawQuery(query);
  }

  Future<List<List<String>>> getSalesData(String posID) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT SUM(Sold), SUM(ItemSales), SUM(DiscCnt), SUM(Disc), SUM(BillDiscCnt), SUM(BillDisc), SUM(ItemFOCCnt), SUM(ItemFOC),  SUM(BillFOCCnt), SUM(BillFOC), SUM(RedeemCnt), SUM(RedeemPoints), SUM(IFNULL(Gratuity,0)), SUM(Tax0), SUM(Tax1), SUM(Tax2), SUM(Tax3), SUM(Tax4), SUM(Tax5), SUM(Tax6), SUM(Tax7), SUM(Tax8), SUM(Tax9), SUM(Tax0 + Tax1 + Tax2 + Tax3 + Tax4 + Tax5 + Tax6 + Tax7 + Tax8 + Tax9), SUM(BillCount), SUM(CoverCount), SUM(VOid), SUM(Refund), SUM(RefundCnt), SUM(VoidCnt), SUM(Surcharge) FROM SalesReport WHERE DeviceID = '$posID'";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    return mapListToString2D(data);
  }

  Future<List<List<String>>> getSalesTrans(String posID) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT FunctionID, Title, SUM(Qty), SUM(Amount + TipAmnt), SUM(ForeignPaidAmnt), SUM(ForeignChangeAmnt) FROM Transactions WHERE DeviceID = '$posID' GROUP BY FunctionID, Title ORDER BY FunctionID, Title";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    return mapListToString2D(data);
  }

  Future<List<List<String>>> getTotalTrans(String posID) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT type, SUM(Qty), SUM(Amount + TipAmnt), SUM(foreignchangeamnt) FROM Transactions INNER JOIN Functions ON Transactions.FunctionID = Functions.FunctionID WHERE DeviceID = '$posID' GROUP BY type";

    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return mapListToString2D(data);
  }

  Future<List<List<String>>> getTaxApplied(String taxCode) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        'SELECT TaxRate, Title FROM TaxRates WHERE TaxCode = $taxCode';
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return mapListToString2D(data);
  }

  Future<List<List<String>>> getSNoRange(String date1, String date2) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT MIN(SalesNo), MAX(SalesNo) FROM SalesTblsTemp WHERE ((Close_Date || ' ' || Close_Time) >= '$date1') AND ((Close_Date || ' ' || Close_Time) <= '$date2')";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return mapListToString2D(data);
  }

  Future<List<List<String>>> getSalesPending(String date1, String date2) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT SUM(Quantity * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * ItemAmount * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (IFNULL(PromotionSaving,0) <> 0 OR IFNULL(Discount,0) <> 0) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (FOCType = 'FOC Item') THEN 0 ELSE 1 END), SUM((IFNULL(Discount,0) + IFNULL(PromotionSaving,0)) * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (FOCType = 'FOC Item') THEN 0 ELSE 1 END), SUM((1) * CASE WHEN (FunctionID = 25) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(ItemAmount * CASE WHEN (FunctionID = 25) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (FOCType = 'FOC Item') THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM((Quantity * ItemAmount) * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (FOCType = 'FOC Item') THEN 1 ELSE 0 END) FROM HeldItems WHERE ((SDate || ' ' || STime) >= '$date1') AND ((SDate || ' ' || STime) <= '$date2') AND (TransStatus = ' ' OR TransStatus = 'S')";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return mapListToString2D(data);
  }

  Future<List<List<String>>> getTotalSales(String date1, String date2) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT SUM(GTotal * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END) FROM SalesTblsTemp WHERE (Close_Date || ' ' || Close_Time) >= '$date1' AND (Close_Date || ' ' || Close_Time) <= '$date2'";

    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return mapListToString2D(data);
  }

  Future<List<List<String>>> refundSummary(String date1, String date2) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT SUM(Quantity * CASE WHEN (TransMode = 'RFND') THEN 1 ELSE 0 END * CASE WHEN (TransStatus = ' ') THEN 1 ELSE 0 END * CASE WHEN (FunctionID NOT IN (24,25)) THEN 1 ELSE 0 END * CASE WHEN (ItemSeqNo <> 101) THEN 1 ELSE 0 END * CASE WHEN (ItemSeqNo <> 102) THEN 1 ELSE 0 END), SUM((Quantity * ItemAmount) * CASE WHEN (TransMode = 'RFND') THEN 1 ELSE 0 END * CASE WHEN (TransStatus = ' ') THEN 1 ELSE 0 END * CASE WHEN (FunctionID NOT IN (24,25)) THEN 1 ELSE 0 END * CASE WHEN (ItemSeqNo <> 101) THEN 1 ELSE 0 END * CASE WHEN (ItemSeqNo <> 102) THEN 1 ELSE 0 END) - SUM(ItemAmount * CASE WHEN (FunctionID IN (24,25)) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'RFND') THEN 1 ELSE 0 END * CASE WHEN (TransStatus = ' ') THEN 1 ELSE 0 END) - SUM(IFNULL(PromotionSaving,0) * CASE WHEN (PromotionType <> '' OR PromotionType IS NULL) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'RFND') THEN 1 ELSE 0 END * CASE WHEN (TransStatus = ' ') THEN 1 ELSE 0 END) FROM SalesItemsTemp WHERE POSID IN ('POS001', 'POS002', 'POS003') AND ((SDate || ' ' || STime) >= '$date1') AND ((SDate || ' ' || STime) <= '$date2')";

    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return mapListToString2D(data);
  }

  Future<List<List<String>>> voidSummary(String date1, String date2) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT SUM(Quantity * CASE WHEN (TransStatus = 'V') THEN 1 ELSE 0 END * CASE WHEN (PostSendVoid = 0 OR PostSendVoid IS NULL) THEN 1 ELSE 0 END * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM((Quantity * ItemAmount) * CASE WHEN (TransStatus = 'V') THEN 1 ELSE 0 END * CASE WHEN (PostSendVoid = 0 OR PostSendVoid IS NULL) THEN 1 ELSE 0 END * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * CASE WHEN (TransStatus = 'V') THEN 1 ELSE 0 END * CASE WHEN (PostSendVoid = 1) THEN 1 ELSE 0 END * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM((Quantity * ItemAmount) * CASE WHEN (TransStatus = 'V') THEN 1 ELSE 0 END * CASE WHEN (PostSendVoid = 1) THEN 1 ELSE 0 END * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END) FROM SalesItemsTemp WHERE POSID IN ('POS001','POS002','POS003') AND ((SDate || ' ' || STime) >= '$date1') AND ((SDate || ' ' || STime) <= '$date2')";

    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return mapListToString2D(data);
  }

  Future<void> doZDaySales(int reportNo, String posID) async {
    final String newDaysSales = currentDateTime('yyyy-MM-dd 00:00:00.0');
    final String newTimesSales = currentDateTime('1900-01-01 HH:mm:ss.0');
    final String query =
        "UPDATE POSDtls SET ZDayReportDt = '$newDaysSales', ZDayReportTime = '$newTimesSales', ZReportNo = $reportNo WHERE POSID = '$posID'";

    final Database dbHandler = await dbHelper.database;
    await dbHandler.rawQuery(query);
  }

  Future<void> zdaySalesSummary(
      int reportNo, String date1, String date2, String posID) async {
    final Database dbHandler = await dbHelper.database;

    final List<List<String>> salesDataArray = await getSalesData(posID);
    final List<List<String>> refundArray = await refundSummary(date1, date2);
    final List<List<String>> voidArray = await voidSummary(date1, date2);
    final List<List<String>> sNoRangeArray = await getSNoRange(date1, date2);
    final List<List<String>> estSalesArray = await getTotalSales(date1, date2);

    double iSalesQty = 0,
        iSalesAmt = 0,
        iDiscQty = 0,
        iDiscAmt = 0,
        billDiscQty = 0,
        billDiscAmt = 0,
        iFOCQty = 0,
        iFOCAmt = 0,
        bFOCQty = 0,
        bFOCAmt = 0;
    int tBill = 0, tCover = 0;
    double tax0 = 0,
        tax1 = 0,
        tax2 = 0,
        tax3 = 0,
        tax4 = 0,
        tax5 = 0,
        tax6 = 0,
        tax7 = 0,
        tax8 = 0,
        tax9 = 0,
        totalTax = 0;

    if (salesDataArray.isNotEmpty) {
      iSalesQty = dynamicToDouble(salesDataArray[0][0]);
      iSalesAmt = dynamicToDouble(salesDataArray[0][1]);
      iDiscQty = dynamicToDouble(salesDataArray[0][2]);
      iDiscAmt = dynamicToDouble(salesDataArray[0][3]);
      billDiscQty = dynamicToDouble(salesDataArray[0][4]);
      billDiscAmt = dynamicToDouble(salesDataArray[0][5]);
      iFOCQty = dynamicToDouble(salesDataArray[0][6]);
      iFOCAmt = dynamicToDouble(salesDataArray[0][7]);
      bFOCQty = dynamicToDouble(salesDataArray[0][8]);
      bFOCAmt = dynamicToDouble(salesDataArray[0][9]);
      tax0 = dynamicToDouble(salesDataArray[0][13]);
      tax1 = dynamicToDouble(salesDataArray[0][14]);
      tax2 = dynamicToDouble(salesDataArray[0][15]);
      tax3 = dynamicToDouble(salesDataArray[0][16]);
      tax4 = dynamicToDouble(salesDataArray[0][17]);
      tax5 = dynamicToDouble(salesDataArray[0][18]);
      tax6 = dynamicToDouble(salesDataArray[0][19]);
      tax7 = dynamicToDouble(salesDataArray[0][20]);
      tax8 = dynamicToDouble(salesDataArray[0][21]);
      tax9 = dynamicToDouble(salesDataArray[0][22]);
      totalTax = dynamicToDouble(salesDataArray[0][23]);
      tBill = dynamicToInt(salesDataArray[0][24]);
      tCover = dynamicToInt(salesDataArray[0][25]);
    }

    final double totalSales =
        iSalesAmt - iDiscAmt - billDiscAmt - iFOCAmt - bFOCAmt;
    final double estSales = dynamicToDouble(estSalesArray[0][0]);

    double refundQty = 0, refundTotal = 0;
    if (refundArray.isNotEmpty) {
      refundQty = dynamicToDouble(refundArray[0][0]);
      refundTotal = dynamicToDouble(refundArray[0][1]);
    }

    double preSendVQty = 0,
        preSendVTotal = 0,
        postSendVQty = 0,
        postSendVTotal = 0;
    if (voidArray.isNotEmpty) {
      preSendVQty = dynamicToDouble(voidArray[0][0]);
      preSendVTotal = dynamicToDouble(voidArray[0][1]);
      postSendVQty = dynamicToDouble(voidArray[0][2]);
      postSendVTotal = dynamicToDouble(voidArray[0][3]);
    }

    int sNoStart = 0, sNoEnd = 0;
    if (sNoRangeArray.isNotEmpty) {
      sNoStart = dynamicToInt(sNoRangeArray[0][0]);
      sNoEnd = dynamicToInt(sNoRangeArray[0][1]);
    }

    final String query =
        "INSERT INTO ZDaySalesSummary (ReportNo, ISalesQty, ISalesTotal, IDiscQty, IDiscTotal, BDiscQty, BDiscTotal, FItemQty, FItemTotal, FBillQty, FBillTotal, TotalSales, EstSales, BillTotal, CoverTotal, PresendVoidQty, PresendVoidTotal, PostsendVoidQty, PostsendVoidTotal, RefundQty, RefundTotal, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, TotalTax, Send, LastZDay, SNoStart, SNoEnd) VALUES ($reportNo, $iSalesQty, $iSalesAmt, $iDiscQty, $iDiscAmt, $billDiscQty, $billDiscAmt, $iFOCQty, $iFOCAmt, $bFOCQty, $bFOCAmt, $totalSales, $estSales, $tBill, $tCover, $preSendVQty, $preSendVTotal, $postSendVQty, $postSendVTotal, $refundQty, $refundTotal, $tax0, $tax1, $tax2, $tax3, $tax4, $tax5, $tax6, $tax7, $tax8, $tax9, $totalTax, 0, '$date2', $sNoStart, $sNoEnd)";
    dbHandler.rawQuery(query);
  }

  Future<void> zdayCollectionSummary(int reportNo, String posID) async {
    final Database dbHandler = await dbHelper.database;

    List<List<String>> mediaArray = await getSalesTrans(posID);
    for (List<String> mediaItem in mediaArray) {
      final int mediaID = dynamicToInt(mediaItem[0]);
      final String mediaTitle = mediaItem[1];
      final double mediaQty = dynamicToDouble(mediaItem[2]);
      final double mediaAmt = dynamicToDouble(mediaItem[3]);
      final String query =
          "INSERT INTO ZDayCollectionSummary (ReportNo, MediaID, MediaName, MediaQty, MediaTotal) VALUES ($reportNo, $mediaID, '$mediaTitle', $mediaQty, $mediaAmt)";
      await dbHandler.rawQuery(query);
    }
  }

  Future<void> zDayItemSummary(
      int reportNo, String date1, String date2, String posID) async {
    final Database dbHandler = await dbHelper.database;
    String query =
        "SELECT PLUNo, ItemName, SUM(Quantity * CASE WHEN (TransStatus = ' ' OR TransStatus = 'D') THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END) AS Quantity, SUM(Quantity * ItemAmount * CASE WHEN (TransStatus = ' ' OR TransStatus = 'D') THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END) AS Amount, SUM(Quantity * CASE WHEN (TransStatus = 'V') THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END) AS Void FROM SalesItemsTemp WHERE (POSID IN ('$posID')) AND ((SDate || ' ' || STime >= '$date1') AND (SDate || ' ' || STime <= '$date2')) AND (FunctionID = 26) GROUP BY ItemName";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    for (Map<String, dynamic> item in data) {
      final String pluNo = item.get(0).toString();
      final String pluName = item.get(1).toString();
      final double pluQty = dynamicToDouble(item.get(2));
      final double pluTotal = dynamicToDouble(item.get(3));
      final double pluVoid = dynamicToDouble(item.get(4));

      query =
          "INSERT INTO ZDayItemSalesSummary (ReportNo, PLUNumber, PLUName, PLUQty, PLUTotal, PLUVoid) VALUES ($reportNo, '$pluNo', '$pluName', $pluQty, $pluTotal, $pluVoid)";
      await dbHandler.rawQuery(query);
    }
  }

  Future<List<List<String>>> getReceiptNo(String date1, String date2) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT MIN(RcptNo), MAX(RcptNo) FROM SalesTblsTemp INNER JOIN SalesItemsTemp ON SalesTblsTemp.SalesNo = SalesItemsTemp.SalesNo WHERE (((SalesItemsTemp.SDate) || ' ' || (SalesItemsTemp.STime)) >= '$date1') AND (((SalesItemsTemp.SDate) || ' ' || (SalesItemsTemp.STime)) <= '$date2')";
    List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<List<List<String>>> getLastZDayData(String posID) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT POSTitle, ZShiftReportDt, ZShiftReportTime, ZDayReportDt, ZDayReportTime, XReportNo, ZReportNo FROM POSDtls WHERE POSID IN ('$posID') ORDER BY POSID";

    final List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<int> checkData() async {
    final Database dbHandler = await dbHelper.database;
    const String query =
        'SELECT DISTINCT HeldTables.SalesNo FROM HeldTables INNER JOIN HeldItems ON HeldTables.SalesNo = HeldItems.SalesNo AND HeldTables.SplitNo = HeldItems.SplitNo';
    final List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    return maps.length;
  }

  Future<int> getReportNo() async {
    final Database dbHandler = await dbHelper.database;
    const String query =
        'SELECT ReportNo FROM ZDaySalesSummary WHERE (Send IS NULL OR Send = 0) LIMIT 1';
    final List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    int reportNo = 0;
    if (maps.isNotEmpty) {
      reportNo = dynamicToInt(maps[0].get(0));
    }
    return reportNo;
  }

  Future<List<List<String>>> getZDaySalesSummary(int reportNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT Coalesce(NULLIF(RTRIM(ReportNo),''),''), Coalesce(NULLIF(RTRIM(ISalesQty),''),''), Coalesce(NULLIF(RTRIM(ISalesTotal),''),''), Coalesce(NULLIF(RTRIM(IDiscQty),''),''), Coalesce(NULLIF(RTRIM(IDiscTotal),''),''), Coalesce(NULLIF(RTRIM(BDiscQty),''),''), Coalesce(NULLIF(RTRIM(BDiscTotal),''),''), Coalesce(NULLIF(RTRIM(FItemQty),''),''), Coalesce(NULLIF(RTRIM(FItemTotal),''),''), Coalesce(NULLIF(RTRIM(FBillQty),''),''), Coalesce(NULLIF(RTRIM(FBillTotal),''),''), Coalesce(NULLIF(RTRIM(TotalSales),''),''), Coalesce(NULLIF(RTRIM(EstSales),''),''), Coalesce(NULLIF(RTRIM(BillTotal),''),''), Coalesce(NULLIF(RTRIM(CoverTotal),''),''), Coalesce(NULLIF(RTRIM(PresendVoidQty),''),''), Coalesce(NULLIF(RTRIM(PresendVoidTotal),''),''), Coalesce(NULLIF(RTRIM(PostsendVoidQty),''),''), Coalesce(NULLIF(RTRIM(PostsendVoidTotal),''),''), Coalesce(NULLIF(RTRIM(RefundQty),''),''), Coalesce(NULLIF(RTRIM(RefundTotal),''),''), Coalesce(NULLIF(RTRIM(Tax0),''),''), Coalesce(NULLIF(RTRIM(Tax1),''),''), Coalesce(NULLIF(RTRIM(Tax2),''),''), Coalesce(NULLIF(RTRIM(Tax3),''),''), Coalesce(NULLIF(RTRIM(Tax4),''),''), Coalesce(NULLIF(RTRIM(Tax5),''),''), Coalesce(NULLIF(RTRIM(Tax6),''),''), Coalesce(NULLIF(RTRIM(Tax7),''),''), Coalesce(NULLIF(RTRIM(Tax8),''),''), Coalesce(NULLIF(RTRIM(Tax9),''),''), Coalesce(NULLIF(RTRIM(TotalTax),''),''), Coalesce(NULLIF(RTRIM(LastZDay),''),''), Coalesce(NULLIF(RTRIM(SNoStart),''),''), Coalesce(NULLIF(RTRIM(SNoEnd),''),'') FROM ZDaySalesSummary WHERE ReportNo = $reportNo LIMIT 1";

    final List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<List<List<String>>> getZDayCollectionSummary(int reportNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT Coalesce(NULLIF(RTRIM(Id),''),''), Coalesce(NULLIF(RTRIM(ReportNo),''),''), Coalesce(NULLIF(RTRIM(MediaID),''),''),  Coalesce(NULLIF(RTRIM(MediaName),''),''), Coalesce(NULLIF(RTRIM(MediaQty),''),''), Coalesce(NULLIF(RTRIM(MediaTotal),''),'') FROM ZDayCollectionSummary WHERE ReportNo = $reportNo";

    final List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<List<List<String>>> getZDayItemSalesSummary(int reportNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT Coalesce(NULLIF(RTRIM(Id),''),''), Coalesce(NULLIF(RTRIM(ReportNo),''),''), Coalesce(NULLIF(RTRIM(PLUNumber),''),''), Coalesce(NULLIF(RTRIM(PLUName),''),''), Coalesce(NULLIF(RTRIM(PLUQty),''),''), Coalesce(NULLIF(RTRIM(PLUTotal),''),''), Coalesce(NULLIF(RTRIM(PLUVoid),''),'') FROM ZDayItemSalesSummary WHERE ReportNo = $reportNo";

    final List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<List<List<String>>> getZDayDtls(String posID) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT Coalesce(NULLIF(RTRIM(ZDayReportDt),''),''), Coalesce(NULLIF(RTRIM(ZDayReportTime),''),''), Coalesce(NULLIF(RTRIM(ZReportNo),''),'') FROM POSDtls WHERE POSID = '$posID'";

    final List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<void> updateZDaySummary(int reportNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        'UPDATE ZDaySalesSummary SET Send = 1 WHERE ReportNo = $reportNo';
    await dbHandler.rawQuery(query);
  }

  // Report
  Future<List<List<String>>> getReportData(String date1, String date2) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT SUM(Quantity * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * ItemAmount * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (IFNULL(PromotionSaving,0) <> 0 OR IFNULL(Discount,0) <> 0) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (FOCType = 'FOC Item') THEN 0 ELSE 1 END), SUM((IFNULL(Discount,0) + IFNULL(PromotionSaving,0)) * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (FOCType = 'FOC Item') THEN 0 ELSE 1 END), SUM((1) * CASE WHEN (FunctionID = 25) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(ItemAmount * CASE WHEN (FunctionID = 25) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (FOCType = 'FOC Item') THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM((Quantity * ItemAmount) * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (FOCType = 'FOC Item') THEN 1 ELSE 0 END), SUM(Quantity * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (FOCType = 'FOC Bill') THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(((Quantity * ItemAmount) - (IFNULL(Discount,0) + IFNULL(PromotionSaving,0))) * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (FunctionID = 26) THEN 1 ELSE 0 END * CASE WHEN (FOCType = 'FOC Bill') THEN 1 ELSE 0 END), SUM(Quantity * CASE WHEN (FunctionID = 27) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(ItemAmount * CASE WHEN (FunctionID = 27) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax0 * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax1 * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax2 * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax3 * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax4 * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax5 * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax6 * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax7 * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax8 * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Tax9 * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * CASE WHEN (TransStatus = 'S') THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Covers * CASE WHEN (TransStatus = 'S') THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(ItemAmount * CASE WHEN (FunctionID = 55) THEN 1 ELSE 0 END * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END) FROM SalesItemsTemp WHERE POSID IN ('POS001', 'POS002', 'POS003') AND ((SDate || ' ' || STime) >= '$date1') AND ((SDate || ' ' || STime) <= '$date2') AND (TransStatus = ' ' OR TransStatus = 'S')";

    final List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<List<List<String>>> getTransReportData(
      String date1, String date2) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT Media.Title, SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(ItemAmount * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(Gratuity,0) <> 0) THEN 1 ELSE 0 END), SUM(IFNULL(Gratuity,0) * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(Gratuity,0) <> 0) THEN 1 ELSE 0 END), SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(RndingAdjustments,0) <> 0) THEN 1 ELSE 0 END), SUM(IFNULL(RndingAdjustments,0) * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(RndingAdjustments,0) <> 0) THEN 1 ELSE 0 END), SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(DepositID,0) > 0) THEN 1 ELSE 0 END), SUM(ItemAmount * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(DepositID,0) > 0) THEN 1 ELSE 0 END), SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(Gratuity,0) <> 0) THEN 1 ELSE 0 END * CASE WHEN (IFNULL(DepositID,0) > 0) THEN 1 ELSE 0 END), SUM(IFNULL(Gratuity,0) * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (IFNULL(Gratuity,0) <> 0) THEN 1 ELSE 0 END * CASE WHEN (IFNULL(DepositID,0) > 0) THEN 1 ELSE 0 END), SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (ChangeAmount <> 0) THEN 1 ELSE 0 END * CASE WHEN (IFNULL(DepositID,0) > 0) THEN 1 ELSE 0 END), SUM(ChangeAmount * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * CASE WHEN (ChangeAmount <> 0) THEN 1 ELSE 0 END * CASE WHEN (IFNULL(DepositID,0) > 0) THEN 1 ELSE 0 END), SUM(IFNULL(ForeignPaidAmnt,0) * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(IFNULL(ChangeAmount,0) * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END * (CASE WHEN IFNULL(foreignpaidamnt,0) = 0 THEN 0 ELSE 1 END)) FROM SalesItemsTemp INNER JOIN Media ON (SalesItemsTemp.FunctionID = Media.FunctionID) AND (SalesItemsTemp.SubFunctionID = Media.SubFunctionID) WHERE POSID IN ('POS001', 'POS002', 'POS003') AND SalesItemsTemp.FunctionID IN (1,2,3,4,5,6,7,8,9) AND ((SDate || ' ' || STime) >= '$date1') AND ((SDate || ' ' || STime) <= '$date2') AND TransStatus = ' ' GROUP BY SalesItemsTemp.FunctionID, SalesItemsTemp.SubFunctionID ORDER BY SalesItemsTemp.FunctionID, Media.Title";

    final List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    return mapListToString2D(maps);
  }

  Future<List<List<String>>> getTotalMediaReport(
      String date1, String date2) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT type, SUM(Quantity * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END), SUM(ItemAmount * CASE WHEN (TransMode = 'REG') THEN 1 ELSE -1 END) FROM SalesItemsTemp INNER JOIN Functions ON SalesItemsTemp.FunctionID = Functions.FunctionID WHERE POSID IN ('POS001', 'POS002', 'POS003') AND (SalesItemsTemp.FunctionID IN (1,2,3,4,5,6,7,8,9)) AND ((SDate || ' ' || STime) >= '$date1') AND ((SDate || ' ' || STime) <= '$date2') AND TransStatus = ' ' GROUP BY type";

    final List<Map<String, dynamic>> maps = await dbHandler.rawQuery(query);
    return mapListToString2D(maps);
  }
}
