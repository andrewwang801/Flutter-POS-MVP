import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../../common/helper/db_helper.dart';
import '../../common/utils/type_util.dart';
import '../model/foc_bill_data_model.dart';
import '../model/media_data_model.dart';
import '../model/payment_details_data_model.dart';
import 'i_payment_repository.dart';

@Injectable(as: IPaymentRepository)
class PaymentLocalRepository with TypeUtil implements IPaymentRepository {
  PaymentLocalRepository({required this.dbHelper});
  final LocalDBHelper dbHelper;

  @override
  Future<bool> checkFOCBillAccess(int salesNo, int splitNo) async {
    final Database dbHandler = await dbHelper.database;

    bool focbillOPAccess = false;
    final String query =
        'SELECT COUNT(PLUNo) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (FOCItem = 0 OR FunctionID IN (24, 25))';
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    if (data.isNotEmpty) {
      final Map<String, dynamic> tempData = data[0];

      if (dynamicToInt(tempData.values.first) > 0) {
        focbillOPAccess = true;
      }
    }

    return focbillOPAccess;
  }

  @override
  Future<bool> checkFocOperatorAccess(int operatorNo, int subFuncID) async {
    final Database dbHandler = await dbHelper.database;

    bool focOPAccess = false;
    final String query =
        'SELECT COUNT(OperatorNo) FROM OperatorFOC WHERE OperatorNo = $operatorNo AND FOCID = $subFuncID';
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    if (data.isNotEmpty) {
      final Map<String, dynamic> tempData = data[0];

      if (dynamicToInt(tempData.values.first) > 0) {
        focOPAccess = true;
      }
    }
    return focOPAccess;
  }

  @override
  Future<bool> checkPaymentPermission(int operatorNo, int paymentType) async {
    final Database db = await dbHelper.database;
    String query =
        'SELECT SubFunctionID, Title FROM Media WHERE SubFunctionID = $paymentType';
    List<Map<String, dynamic>> data = await db.rawQuery(query);
    Map<String, dynamic> tempData = data[0];

    final int subFuncID = cast<int>(tempData.entries.first.value) ?? 0;
    final String mediaName = tempData.entries.elementAt(1).value.toString();

    query =
        'SELECT COUNT(OperatorNo) FROM OperatorMedia WHERE OperatorNo = $operatorNo AND MediaID = $subFuncID';
    data = await db.rawQuery(query);
    tempData = data[0];
    final int cnt = cast<int>(tempData.entries.first.value) ?? 0;
    if (cnt <= 0) {
      GlobalConfig.ErrMsg =
          'Operator does not have permission to tender with Media " $mediaName "';
      return false;
    }
    return true;
  }

  @override
  Future<bool> checkTenderPayment(
      int salesNo, int splitNo, String tableNo) async {
    final Database db = await dbHelper.database;

    final String query =
        "SELECT COUNT(*) FROM HeldItems WHERE ItemSeqNo = 101 AND SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo' AND TransStatus = ' '";
    final List<Map<String, dynamic>> data = await db.rawQuery(query);
    final Map<String, dynamic> tempData = data[0];

    bool isTender = false;
    if ((cast<int>(tempData.entries.first.value) ?? 0) > 0) {
      isTender = true;
    }

    return isTender;
  }

  @override
  Future<int> countData(String query) async {
    final Database db = await dbHelper.database;
    final List<Map<String, dynamic>> data = await db.rawQuery(query);
    if (data.isEmpty) {
      return 0;
    }
    final int cnt = cast<int>(data[0].values.first) ?? 0;
    return cnt;
  }

  @override
  Future<void> doFOCBill(
      int salesNo,
      int splitNo,
      String tableNo,
      int focType,
      String posID,
      int operatorNo,
      int pShift,
      String custID,
      String transMode) async {
    final Database dbHandler = await dbHelper.database;

    final String sDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String sTime = DateFormat('HH:mm:ss.0').format(DateTime.now());

    String query =
        'SELECT FunctionID, Title FROM Media WHERE SubFunctionID = $focType';
    List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    Map<String, dynamic> tempData = data[0];
    if (data.isEmpty) {
      return;
    }
    final int funcID = dynamicToInt(tempData.values.first);
    final String focTitle = tempData.values.elementAt(1).toString();

    query =
        "SELECT TAmnt, Disc, Surcharge FROM (SELECT SUM(Quantity * ItemAmount * CASE WHEN FunctionID = 26 THEN  1 ELSE 0 END) AS TAmnt, SUM((IFNULL(Discount, 0) + IFNULL(PromotionSaving, 0)) * CASE WHEN FunctionID = 25 OR FunctionID = 26 THEN 1 ELSE 0 END) AS Disc, SUM(IFNULL(Discount, 0) * CASE WHEN FunctionID = 55 THEN 1 ELSE 0 END) AS Surcharge FROM HeldItems WHERE SalesNo = $salesNo AND Splitno  = $splitNo AND FOCType <> 'FOC Item' AND (TransStatus = ' ' OR TransStatus = 'O')) AS a";
    data = await dbHandler.rawQuery(query);
    tempData = data[0];

    final double sTotal = dynamicToDouble(tempData.values.first);
    final double discount = dynamicToDouble(tempData.values.elementAt(1));
    final double surcharge = dynamicToDouble(tempData.values.elementAt(2));
    final double amount = sTotal - discount + surcharge;

    query =
        'SELECT IFNULL(MembershipID, 0), RcptNo, Covers FROM HeldTables WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    data = await dbHandler.rawQuery(query);
    tempData = data[0];

    final int memId = dynamicToInt(tempData.values.first);
    String rcptNo = tempData.values.elementAt(1).toString();
    final int cover = dynamicToInt(tempData.values.elementAt(2));

    query = 'SELECT inclusive FROM TaxRates WHERE SalesTax = 1';
    data = await dbHandler.rawQuery(query);
    tempData = data[0];

    bool itemTaxInc = false;
    if (dynamicToInt(tempData.values.first) > 0) {
      itemTaxInc = true;
    }

    final List<double> taxArray = await findTax(salesNo, splitNo, tableNo, 2);
    final double TTax0 = taxArray[0];
    final double TTax1 = taxArray[1];
    final double TTax2 = taxArray[2];
    final double TTax3 = taxArray[3];
    final double TTax4 = taxArray[4];
    final double TTax5 = taxArray[5];
    final double TTax6 = taxArray[6];
    final double TTax7 = taxArray[7];
    final double TTax8 = taxArray[8];
    final double TTax9 = taxArray[9];
    double GTotal = amount;

    if (!itemTaxInc) {
      GTotal = GTotal +
          TTax0 +
          TTax1 +
          TTax2 +
          TTax3 +
          TTax4 +
          TTax5 +
          TTax6 +
          TTax7 +
          TTax8 +
          TTax9;
    } else {
      GTotal = GTotal +
          TTax1 +
          TTax2 +
          TTax3 +
          TTax4 +
          TTax5 +
          TTax6 +
          TTax7 +
          TTax8 +
          TTax9;
    }

    query =
        'SELECT COUNT(OperatorNo) FROM OperatorFOC WHERE OperatorNo = $operatorNo AND FOCID = $focType';
    data = await dbHandler.rawQuery(query);
    tempData = data[0];
    final int opCount = dynamicToInt(tempData.values.first);

    if (opCount <= 0) {
      GlobalConfig.ErrMsg =
          'Operator does not have permission for FOC $focTitle';
    } else {
      query =
          'INSERT INTO HeldItems (POSID, OperatorNo, Covers, TableNo, SalesNo, SplitNo, PLUSalesRef, ItemSeqNo, PLUNo, Department, SDate, STime, Quantity, ItemName, ItemName_Chinese, ItemAmount, PaidAmount, ChangeAmount, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, DiscountType, DiscountPercent, Discount, PromotionId, PromotionType, PromotionSaving, TransMode, RefundID, TransStatus, FunctionID, SubFunctionID, MembershipID, LoyaltyCardNo, CustomerID, AvgCost, RecipeId, PriceShift, CategoryId, Preparation, FOCItem, FOCType, ApplyTax0, ApplyTax1, ApplyTax2, ApplyTax3, ApplyTax4, ApplyTax5, ApplyTax6, ApplyTax7, ApplyTax8, ApplyTax9, LnkTo, Setmenu, SetMenuRef, TblHold, SeatNo, ServerNo, TaxTag, KDSPrint)';
      String values =
          " VALUES ( '$posID', $operatorNo, $cover, '$tableNo', $salesNo, $splitNo, 0, 101, '000000000000000', 0, '$sDate', '$sTime', 1, '$focTitle', '$focTitle', $amount, $amount, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '', 0, 0.00, 0, '', 0.00, '$transMode', 0, ' ', %funcID , $focType, $memId, '', '$custID', 0.00, 0, $pShift, ${POSDtls.categoryID}, 0, 1, 'FOC Bill', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'N', 0, 0, 0, 0, $operatorNo, 'V', 0 )";

      query += values;
      await dbHandler.rawQuery(query);

      query =
          'INSERT INTO HeldItems (POSID, OperatorNo, Covers, TableNo, SalesNo, SplitNo, PLUSalesRef, ItemSeqNo, PLUNo, Department, SDate, STime, Quantity, ItemName, ItemName_Chinese, ItemAmount, PaidAmount, ChangeAmount, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, DiscountType, DiscountPercent, Discount, PromotionId, PromotionType, PromotionSaving, TransMode, RefundID, TransStatus, FunctionID, SubFunctionID, MembershipID, LoyaltyCardNo, CustomerID, AvgCost, RecipeId, PriceShift, CategoryId, Preparation, FOCItem, FOCType, ApplyTax0, ApplyTax1, ApplyTax2, ApplyTax3, ApplyTax4, ApplyTax5, ApplyTax6, ApplyTax7, ApplyTax8, ApplyTax9, LnkTo, Setmenu, SetMenuRef, TblHold, SeatNo, ServerNo, OperatorFOC, TaxTag, KDSPrint)';
      values =
          " VALUES ( '$posID', $operatorNo, $cover, '$tableNo', $salesNo, $splitNo, 0, 102, '000000000000000', 0, '$sDate', '$sTime', 1, 'CLOSE', 'CLOSE', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '', 0, 0.00, 0, '', 0.00, '$transMode', 0, 'S', $funcID, $focType, $memId, '', '$custID', 0.00, 0, $pShift, ${POSDtls.categoryID}, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'N', 0, 0, 0, 0, $operatorNo, $operatorNo, 'V', 0 )";

      query += values;
      await dbHandler.rawQuery(query);

      if (rcptNo == '') {
        query =
            'SELECT Count(RcptNo), RcptNo FROM HeldTables WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
        data = await dbHandler.rawQuery(query);
        tempData = data[0];

        if (dynamicToInt(tempData.values.first) > 0) {
          rcptNo = tempData.values.elementAt(1).toString();
        } else {
          GlobalConfig.ErrMsg = 'Receipt Number Not Found.';
          return;
        }

        if (rcptNo == '000000000000000') {
          GlobalConfig.ErrMsg = 'Generate Receipt Number Failed.';
          return;
        }

        if (GlobalConfig.ErrMsg == '') {
          query =
              'INSERT INTO RcptDtls(ReceiptNo, OperatorNo, TableNo, SplitNo, SalesNo, Finalized, Printed, Void, TaxExempt, CopyNo)';
          values =
              " VALUES ( '$rcptNo', $operatorNo, '$tableNo', $splitNo, $salesNo, 1, 0, 0, 0, 0";

          query += values;
          await dbHandler.rawQuery(query);
        }
      }

      query =
          "UPDATE HeldItems SET FOCItem = 1, FOCType = 'FOC Bill', CustomerID = '$custID', OperatorFOC = $operatorNo WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo' AND FOCType = ' '";
      await dbHandler.rawQuery(query);

      query =
          "SELECT IFNULL(SUM(ItemAmount), 0) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TransStatus = ' ' AND FunctionID IN (1,2,3,4,5,6,7,8,9)";
      data = await dbHandler.rawQuery(query);
      tempData = data[0];

      final double paidAmnt = dynamicToDouble(tempData.values.first);
      final double balance = GTotal - paidAmnt;

      query =
          "UPDATE HeldTables SET STotal = $sTotal, GTotal = $GTotal, PaidAmount = $paidAmnt, Balance = $balance, Close_Date = '$sDate', Close_Time = '$sTime' WHERE SalesNo = $salesNo AND SplitNo = $splitNo";
      await dbHandler.rawQuery(query);

      await moveSales(salesNo, splitNo);
      await moveSales2(salesNo, splitNo);
      await moveSales3(salesNo, splitNo);

      query =
          'DELETE FROM temp_VPrmn WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
      await dbHandler.rawQuery(query);

      if (tableNo != '') {
        query =
            "SELECT COUNT(TableNo) FROM HeldTables WHERE TableNo = '$tableNo'";
        data = await dbHandler.rawQuery(query);
        tempData = data[0];

        final int countTable = dynamicToInt(tempData.values.first);
        if (countTable < 1) {
          query =
              "UPDATE TblLayout SET TBLStatus = 'A' WHERE TBLNo = '$tableNo'";
          await dbHandler.rawQuery(query);
        } else {
          query =
              "UPDATE TblLayout SET TBLStatus = 'O' WHERE TBLNo IN (SELECT TableNo FROM HeldTables WHERE TableNo = '$tableNo')";
          await dbHandler.rawQuery(query);
        }
      }
    }
  }

  @override
  Future<void> doRemovePayment(
      int salesNo, int splitNo, String tableNo, int salesRef) async {
    final Database dbHandler = await dbHelper.database;

    final DateTime now = DateTime.now();
    final String dateIn = DateFormat('yyyy-MM-dd').format(now);
    final String timeIn = DateFormat('07:00:00.0').format(now);
    final String tempDateTime = '$dateIn $timeIn';

    String query =
        "SELECT IFNULL(SUM(VoidCount),0) FROM OpHistory WHERE (DateIn || ' ' || TimeIn) = '$tempDateTime' AND OperatorNo = ${GlobalConfig.operatorNo}";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    int sVoidCount = 0;
    if (data.isNotEmpty) {
      sVoidCount = dynamicToInt(data[0].values.first);
    }

    query =
        "UPDATE OpHistory SET VoidCount = ($sVoidCount + 1) WHERE LstLogin = 1 AND POSID = 'POSDtls.DeviceNo' AND OperatorNo = ${GlobalConfig.operatorNo}";
    await dbHandler.rawQuery(query);

    query =
        "UPDATE HeldItems SET TransStatus = 'V' WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND SalesRef = $salesRef AND TableNo = '$tableNo'";
    await dbHandler.rawQuery(query);

    query =
        "UPDATE HeldItems SET TransStatus = 'V', PostSendVoid = 1 WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TblHold = 1 AND SalesRef = $salesRef AND TableNo = '$tableNo'";
    await dbHandler.rawQuery(query);

    final String sDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String sTime = DateFormat('HH:mm:ss.0').format(DateTime.now());

    query =
        "INSERT INTO HeldItems (POSID, Covers, TableNo, SalesNo, SplitNo, PLUSalesRef, PLUNo, Department, Quantity, ItemName, ItemAmount, PaidAmount, ChangeAmount, Gratuity, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, Adjustment, DiscountType, DiscountPercent, Discount, PromotionId, PromotionType, PromotionSaving, TransMode, RefundID, MembershipID, LoyaltyCardNo, CustomerID, CardScheme, CreditCardNo, AvgCost, RecipeId, PriceShift, CategoryId, TransferredTable, TransferredOp, KitchenPrint1, KitchenPrint2, KitchenPrint3, RedemptionItem, PointsRedeemed, ShiftID, PrintFreePrep, PrintPrepWithPrice, Preparation, FOCItem, FOCType, ApplyTax0, ApplyTax1, ApplyTax2, ApplyTax3, ApplyTax4, ApplyTax5, ApplyTax6, ApplyTax7, ApplyTax8, ApplyTax9, LnkTo, BuyXfreeYapplied, RndingAdjustments, PostSendVoid, TblHold, DepositID, SeatNo, OperatorNo, ItemSeqNo, SDate, STime, TransStatus, FunctionID, SubFunctionID, serverno) SELECT HeldItems.POSID, HeldItems.Covers, HeldItems.TableNo, HeldItems.SalesNo, HeldItems.SplitNo, HeldItems.SalesRef, HeldItems.PLUNo, HeldItems.Department, HeldItems.Quantity, HeldItems.ItemName, HeldItems.ItemAmount, HeldItems.PaidAmount, HeldItems.ChangeAmount, HeldItems.Gratuity, HeldItems.Tax0, HeldItems.Tax1, HeldItems.Tax2, HeldItems.Tax3,  HeldItems.Tax4, HeldItems.Tax5, HeldItems.Tax6, HeldItems.Tax7, HeldItems.Tax8, HeldItems.Tax9, HeldItems.Adjustment, HeldItems.DiscountType, HeldItems.DiscountPercent, HeldItems.Discount, HeldItems.PromotionId, HeldItems.PromotionType, HeldItems.PromotionSaving, HeldItems.TransMode, HeldItems.RefundID, HeldItems.MembershipID, HeldItems.LoyaltyCardNo, HeldItems.CustomerID, HeldItems.CardScheme, HeldItems.CreditCardNo, HeldItems.AvgCost, HeldItems.RecipeId, HeldItems.PriceShift, HeldItems.CategoryId, HeldItems.TransferredTable, HeldItems.TransferredOp, HeldItems.KitchenPrint1, HeldItems.KitchenPrint2, HeldItems.KitchenPrint3, HeldItems.RedemptionItem, HeldItems.PointsRedeemed, HeldItems.ShiftID, HeldItems.PrintFreePrep, HeldItems.PrintPrepWithPrice, HeldItems.Preparation, HeldItems.FOCItem, HeldItems.FOCType, HeldItems.ApplyTax0, HeldItems.ApplyTax1, HeldItems.ApplyTax2, HeldItems.ApplyTax3, HeldItems.ApplyTax4, HeldItems.ApplyTax5, HeldItems.ApplyTax6, HeldItems.ApplyTax7, HeldItems.ApplyTax8, HeldItems.ApplyTax9, HeldItems.LnkTo, HeldItems.BuyXfreeYapplied, HeldItems.RndingAdjustments, HeldItems.PostSendVoid, HeldItems.TblHold, HeldItems.DepositID, HeldItems.SeatNo, ${GlobalConfig.operatorNo}, HeldItems.ItemSeqNo, '$sDate', '$sTime', 'N', HeldItems.FunctionID, HeldItems.SubFunctionID, ${GlobalConfig.operatorNo} FROM HeldItems WHERE HeldItems.SalesRef = $salesRef";
    await dbHandler.rawQuery(query);
  }

  @override
  Future<List<double>> getAmountOrder(
      int salesNo, int splitNo, int tableNo, bool taxIncl) async {
    double tTax0 = 0.0;
    double tTax1 = 0.0;
    double tTax2 = 0.0;
    double tTax3 = 0.0;
    double tTax4 = 0.0;
    double tTax5 = 0.0;
    double tTax6 = 0.0;
    double tTax7 = 0.0;
    double tTax8 = 0.0;
    double tTax9 = 0.0;

    final Database db = await dbHelper.database;
    String query = 'SELECT inclusive FROM TaxRates WHERE SalesTax = 1';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    final bool itemTaxIncl = (maps[0].entries.first.value as int).toBool();

    query =
        "SELECT IFNULL(TAmnt, 0), IFNULL(Disc, 0), IFNULL(Surcharge, 0) FROM (SELECT SUM(Quantity * ItemAmount * CASE WHEN (FunctionID = 26 AND FOCItem = 0) THEN 1 ELSE 0 END) AS TAmnt, SUM((IFNULL(Discount, 0) + IFNULL(PromotionSaving, 0)) * CASE WHEN (FunctionID = 25 OR FunctionID = 26) AND FOCItem = 0 THEN 1 ELSE 0 END) AS Disc, SUM(IFNULL(Discount, 0) * CASE WHEN FunctionID = 55 THEN 1 ELSE 0 END) AS Surcharge FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D')) AS a";
    maps = await db.rawQuery(query);
    double tAmnt = 0.00, disc = 0.00, surCharge = 0.00;
    if (maps.isNotEmpty) {
      final Map<String, dynamic> tempData = maps[0];
      tAmnt = dynamicToDouble(tempData.entries.elementAt(0).value);
      disc = dynamicToDouble(tempData.entries.elementAt(1).value);
      surCharge = dynamicToDouble(tempData.entries.elementAt(2).value);
    }

    final double sTotal = tAmnt;
    double gTotal = sTotal - disc + surCharge;
    const double taxTotal = 0.00;

    if (!taxIncl) {
      final List<double> taxList =
          await findTax(salesNo, splitNo, tableNo.toString(), 2);
      // List<double> taxList = [];

      tTax0 = taxList[0];
      tTax1 = taxList[1];
      tTax2 = taxList[2];
      tTax3 = taxList[3];
      tTax4 = taxList[4];
      tTax5 = taxList[5];
      tTax6 = taxList[6];
      tTax7 = taxList[7];
      tTax8 = taxList[8];
      tTax9 = taxList[9];

      if (!itemTaxIncl) {
        gTotal = gTotal +
            tTax0 +
            tTax1 +
            tTax2 +
            tTax3 +
            tTax4 +
            tTax5 +
            tTax6 +
            tTax7 +
            tTax8 +
            tTax9;
      } else {
        gTotal = gTotal +
            tTax1 +
            tTax2 +
            tTax3 +
            tTax4 +
            tTax5 +
            tTax6 +
            tTax7 +
            tTax8 +
            tTax9;
      }
    } else {
      final List<double> taxList =
          await findTax(salesNo, splitNo, tableNo.toString(), 2);
      // List<double> taxList = [];

      tTax0 = taxList[0];
      tTax1 = taxList[1];
      tTax2 = taxList[2];
      tTax3 = taxList[3];
      tTax4 = taxList[4];
      tTax5 = taxList[5];
      tTax6 = taxList[6];
      tTax7 = taxList[7];
      tTax8 = taxList[8];
      tTax9 = taxList[9];
    }
    final List<double> taxData = <double>[
      gTotal,
      taxTotal,
      sTotal,
      disc,
      tTax0,
      tTax1,
      tTax2,
      tTax3,
      tTax4,
      tTax5,
      tTax6,
      tTax7,
      tTax8,
      tTax9
    ];
    return taxData;
  }

  @override
  Future<List<double>> findExTax(int salesNo, int splitNo, String tableNo,
      int digit, bool PLUBillDisc) async {
    final Database db = await dbHelper.database;

    double TaxRate1;
    double TaxRate2;
    double TaxRate3;
    double TaxRate4;
    double Tax1;
    double Tax2;
    double Tax3;
    double Tax4;
    double NetAmnt = 0.0;
    double STax;
    double TPercent;
    double ItemTotal = 0.0;
    double ItemDisc = 0.0;
    double TaxRate;
    int TaxCode;
    double STaxRate;
    double Amnt;
    double GTotal;
    double BillDiscP;
    String StrTax = '';
    bool PLUTaxExempt;
    String PLUNo;
    bool AllowDisc;
    double SSub;
    String TableName;
    double BillDisc = 0.0;
    double TTax = 0.0;
    double TTax0 = 0.0;
    double TTax1 = 0.0;
    double TTax2 = 0.0;
    double TTax3 = 0.0;
    double TTax4 = 0.0;
    double TTax5 = 0.0;
    double TTax6 = 0.0;
    double TTax7 = 0.0;
    double TTax8 = 0.0;
    double TTax9 = 0.0;
    double STotal = 0.0;
    double TotTax0 = 0.0;
    double TotTax1 = 0.0;
    double TotTax2 = 0.0;
    double TotTax3 = 0.0;
    double TotTax4 = 0.0;
    double TotTax5 = 0.0;
    double TotTax6 = 0.0;
    double TotTax7 = 0.0;
    double TotTax8 = 0.0;
    double TotTax9 = 0.0;
    double AllItemTotal = 0.0;
    double TSub0 = 0.0;
    double TSub1 = 0.0;
    double TSub2 = 0.0;
    double TSub3 = 0.0;
    double TSub4 = 0.0;
    double TSub5 = 0.0;
    double TSub6 = 0.0;
    double TSub7 = 0.0;
    double TSub8 = 0.0;
    double TSub9 = 0.0;
    double TotSub0 = 0.0;
    double TotSub1 = 0.0;
    double TotSub2 = 0.0;
    double TotSub3 = 0.0;
    double TotSub4 = 0.0;
    double TotSub5 = 0.0;
    double TotSub6 = 0.0;
    double TotSub7 = 0.0;
    double TotSub8 = 0.0;
    double TotSub9 = 0.0;

    // ignore: avoid_escaping_inner_quotes
    String query =
        'SELECT COUNT(SalesNo) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    final int count = await countData(query);
    if (count > 0) {
      TableName = 'HeldItems';
    } else {
      TableName = 'SalesItemsTemp';
    }

    if (!PLUBillDisc) {
      query =
          "SELECT IFNULL(SUM(Quantity * ItemAmount * CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END), 0), IFNULL(SUM((IFNULL(PromotionSaving, 0) + IFNULL(Discount, 0)) * (CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END)), 0) FROM $TableName WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D')";
      final List<Map<String, dynamic>> data1 = await db.rawQuery(query);
      final Map<String, dynamic> tempdata1 = data1[0];
      final double amount = dynamicToDouble(tempdata1.values.first);
      final double disc = dynamicToDouble(tempdata1.values.elementAt(1));
      AllItemTotal = amount - disc;
    } else {
      query =
          "SELECT IFNULL(SUM((Quantity * ItemAmount) * (CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END)), 0), IFNULL(SUM((IFNULL(Discount, 0) + IFNULL(PromotionSaving, 0)) * (CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END)), 0) FROM $TableName a, PLU b WHERE SalesNo = $salesNo AND FOCType NOT IN ('FOC Item', 'BuyXfreeY') AND (TransStatus = ' ' OR TransStatus = 'D') AND SplitNo = $splitNo AND b.PLUNumber = a.PLUNo AND b.AllowDiscount = 1";
      final List<Map<String, dynamic>> data1 = await db.rawQuery(query);
      final Map<String, dynamic> tempdata1 = data1[0];
      final double amount = dynamicToDouble(tempdata1.values.elementAt(0));
      final double disc = dynamicToDouble(tempdata1.values.elementAt(1));
      AllItemTotal = amount - disc;
    }

    query =
        "SELECT DISTINCT PLUNo, AllowDiscount FROM $TableName a INNER JOIN PLU b ON a.PLUNo = b.PLUNumber WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TransStatus = ' '";
    final List<Map<String, dynamic>> data = await db.rawQuery(query);
    final int TableCount = data.length;

    for (int i = 0; i < TableCount; i++) {
      final Map<String, dynamic> tempdata = data[i];
      PLUNo = tempdata.values.elementAt(0).toString();
      AllowDisc = dynamicToBool(tempdata.values.elementAt(1));

      query =
          "SELECT IFNULL(SUM((Quantity * ItemAmount) * (CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END)),0) FROM $TableName WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND PLUNo = '$PLUNo'";
      List<Map<String, dynamic>> data1 = await db.rawQuery(query);
      Map<String, dynamic> tempdata1 = data[0];
      ItemTotal = dynamicToDouble(tempdata1.values.elementAt(0));

      query =
          "SELECT IFNULL(SUM((IFNULL(PromotionSaving,0) + IFNULL(Discount,0)) * (CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END)),0) FROM $TableName WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND PLUNo = '$PLUNo'";
      data1 = await db.rawQuery(query);
      tempdata1 = data1[0];
      ItemDisc = dynamicToDouble(tempdata1.values.elementAt(0));

      query =
          "SELECT IFNULL(Quantity * ItemAmount,0) FROM $TableName WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND FunctionID = 25 AND ItemAmount <> 0 AND TransStatus = ' '";
      data1 = await db.rawQuery(query);
      tempdata1 = data1[0];
      BillDisc = dynamicToDouble(tempdata1.values.elementAt(0));

      if (!PLUBillDisc || AllowDisc) {
        if (AllItemTotal > 0) {
          BillDiscP = (ItemTotal - ItemDisc) / AllItemTotal;
          BillDisc = (BillDiscP * BillDisc * 100) / 100;
        } else {
          BillDisc = 0.00;
        }
      } else {
        BillDisc = 0.00;
      }

      STotal = ItemTotal - ItemDisc;
      GTotal = STotal - BillDisc;

      query = "SELECT plutaxexempt FROM PLU WHERE PLUNumber = '$PLUNo'";
      data1 = await db.rawQuery(query);
      tempdata1 = data1[0];
      PLUTaxExempt = dynamicToBool(tempdata1.values.elementAt(0));

      if (PLUTaxExempt) {
        query =
            "SELECT CASE WHEN exmpttax0 = 1 THEN '0,' ELSE '' END, CASE WHEN exmpttax1 = 1 THEN '1,' ELSE '' END, CASE WHEN exmpttax2 = 1 THEN '2,' ELSE '' END, CASE WHEN exmpttax3 = 1 THEN '3,' ELSE '' END, CASE WHEN exmpttax4 = 1 THEN '4,' ELSE '' END, CASE WHEN exmpttax5 = 1 THEN '5,' ELSE '' END, CASE WHEN exmpttax6 = 1 THEN '6,' ELSE '' END, CASE WHEN exmpttax7 = 1 THEN '7,' ELSE '' END, CASE WHEN exmpttax8 = 1 THEN '8,' ELSE '' END, CASE WHEN exmpttax9 = 1 THEN '9' ELSE '' END FROM PLU WHERE PLUNumber = '$PLUNo'";
        data1 = await db.rawQuery(query);
        tempdata1 = data1[0];
        tempdata1.forEach((key, value) {
          StrTax += value.toString();
        });

        if (StrTax.isNotEmpty) {
          StrTax = StrTax.substring(0, StrTax.length - 1);
        } else {
          StrTax = '';
        }

        if (StrTax != '') {
          query =
              'SELECT IFNULL(SUM(TaxRate * (CASE WHEN AppliesToNett = 0 THEN 1 ELSE 0 END) * (CASE WHEN DiscInclusive = 1 THEN 1 ELSE 0 END)),0), IFNULL(SUM(TaxRate * (CASE WHEN AppliesToNett = 0 THEN 1 ELSE 0 END) * (CASE WHEN DiscInclusive = 0 THEN 1 ELSE 0 END)),0), IFNULL(SUM(TaxRate * (CASE WHEN AppliesToNett = 1 THEN 1 ELSE 0 END) * (CASE WHEN DiscInclusive = 1 THEN 1 ELSE 0 END)),0), IFNULL(SUM(TaxRate * (CASE WHEN AppliesToNett = 1 THEN 1 ELSE 0 END) * (CASE WHEN DiscInclusive = 0 THEN 1 ELSE 0 END)),0) FROM TaxRates WHERE TaxCode NOT IN ($StrTax)';
        } else {
          query =
              'SELECT IFNULL(SUM(TaxRate * (CASE WHEN AppliesToNett = 0 THEN 1 ELSE 0 END) * (CASE WHEN DiscInclusive = 1 THEN 1 ELSE 0 END)),0), IFNULL(SUM(TaxRate * (CASE WHEN AppliesToNett = 0 THEN 1 ELSE 0 END) * (CASE WHEN DiscInclusive = 0 THEN 1 ELSE 0 END)),0), IFNULL(SUM(TaxRate * (CASE WHEN AppliesToNett = 1 THEN 1 ELSE 0 END) * (CASE WHEN DiscInclusive = 1 THEN 1 ELSE 0 END)),0), IFNULL(SUM(TaxRate * (CASE WHEN AppliesToNett = 1 THEN 1 ELSE 0 END) * (CASE WHEN DiscInclusive = 0 THEN 1 ELSE 0 END)),0) FROM TaxRates';
        }
      } else {
        query =
            'SELECT IFNULL(SUM(TaxRate * (CASE WHEN AppliesToNett = 0 THEN 1 ELSE 0 END) * (CASE WHEN DiscInclusive = 1 THEN 1 ELSE 0 END)),0), IFNULL(SUM(TaxRate * (CASE WHEN AppliesToNett = 0 THEN 1 ELSE 0 END) * (CASE WHEN DiscInclusive = 0 THEN 1 ELSE 0 END)),0), IFNULL(SUM(TaxRate * (CASE WHEN AppliesToNett = 1 THEN 1 ELSE 0 END) * (CASE WHEN DiscInclusive = 1 THEN 1 ELSE 0 END)),0), IFNULL(SUM(TaxRate * (CASE WHEN AppliesToNett = 1 THEN 1 ELSE 0 END) * (CASE WHEN DiscInclusive = 0 THEN 1 ELSE 0 END)),0) FROM TaxRates';
      }

      data1 = await db.rawQuery(query);
      tempdata1 = data1[0];
      TaxRate1 = dynamicToDouble(tempdata1.values.elementAt(0));
      TaxRate2 = dynamicToDouble(tempdata1.values.elementAt(1));
      TaxRate3 = dynamicToDouble(tempdata1.values.elementAt(2));
      TaxRate4 = dynamicToDouble(tempdata1.values.elementAt(3));

      Tax1 = 0.00;
      if (TaxRate1 > 0) {
        STaxRate = 1 + (TaxRate1 / 100);
        Tax1 = ItemTotal - (ItemTotal / STaxRate);
      }

      Tax2 = 0.00;
      if (TaxRate2 > 0) {
        STaxRate = 1 + (TaxRate2 / 100);
        Tax2 = ItemTotal - (ItemTotal / STaxRate);
      }

      Tax3 = 0.00;
      if (TaxRate3 > 0) {
        STaxRate = 1 + (TaxRate3 / 100);
        Tax3 = ItemTotal - (ItemTotal / STaxRate);
      }

      Tax4 = 0.00;
      if (TaxRate4 > 0) {
        STaxRate = 1 + (TaxRate4 / 100);
        Tax4 = ItemTotal - (ItemTotal / STaxRate);
      }

      NetAmnt = NetAmnt - (Tax3 + Tax4);

      bool exemptable, discinclusive, appliesToNett, salesTax;
      String title;

      if (PLUTaxExempt && StrTax != '') {
        query =
            'SELECT TaxCode, Exemptable, DiscInclusive, TaxRate, Title, AppliesToNett, SalesTax FROM TaxRates WHERE TaxRate > 0 AND TaxCode NOT IN ($StrTax) ORDER BY AppliesToNett Desc, TaxCode';
      } else {
        query =
            'SELECT TaxCode, Exemptable, DiscInclusive, TaxRate, Title, AppliesToNett, SalesTax FROM TaxRates WHERE TaxRate > 0 ORDER BY AppliesToNett Desc, TaxCode';
      }

      data1 = await db.rawQuery(query);
      final int TableCount2 = data1.length;

      for (int j = 0; j < TableCount2; j++) {
        tempdata1 = data1[j];
        TaxCode = dynamicToInt(tempdata1.values.elementAt(0));
        exemptable = dynamicToBool(tempdata1.values.elementAt(1));
        discinclusive = dynamicToBool(tempdata1.values.elementAt(2));
        TPercent = dynamicToDouble(tempdata1.values.elementAt(3));
        title = tempdata1.values.elementAt(4).toString();
        appliesToNett = dynamicToBool(tempdata1.values.elementAt(5));
        salesTax = dynamicToBool(tempdata1.values.elementAt(6));

        TaxRate = TPercent / 100;
        STax = 0.0;

        if (ItemTotal == 0) {
          STax = 0.0;
        } else {
          if (!discinclusive) {
            Amnt = NetAmnt;
          } else
            Amnt = NetAmnt + (ItemDisc + BillDisc);

          if (appliesToNett) {
            STax = Amnt * TaxRate;
            SSub = Amnt;
          } else {
            STax = (Amnt + TTax) * TaxRate;
            SSub = (Amnt + TTax);
          }

          if (salesTax) {
            STax = (TTax + Amnt) * TaxRate;
            SSub = (TTax + Amnt);
          }

          //STax = STax;
          TTax = TTax + STax;

          if (TaxCode == 0) {
            TTax0 = STax;
            TSub0 = SSub;
          }
          if (TaxCode == 1) {
            TTax1 = STax;
            TSub1 = SSub;
          }
          if (TaxCode == 2) {
            TTax2 = STax;
            TSub2 = SSub;
          }
          if (TaxCode == 3) {
            TTax3 = STax;
            TSub3 = SSub;
          }
          if (TaxCode == 4) {
            TTax4 = STax;
            TSub4 = SSub;
          }
          if (TaxCode == 5) {
            TTax5 = STax;
            TSub5 = SSub;
          }
          if (TaxCode == 6) {
            TTax6 = STax;
            TSub6 = SSub;
          }
          if (TaxCode == 7) {
            TTax7 = STax;
            TSub7 = SSub;
          }
          if (TaxCode == 8) {
            TTax8 = STax;
            TSub8 = SSub;
          }
          if (TaxCode == 9) {
            TTax9 = STax;
            TSub9 = SSub;
          }
        }
      }

      TotTax0 = TotTax0 + TTax0;
      TotTax1 = TotTax1 + TTax1;
      TotTax2 = TotTax2 + TTax2;
      TotTax3 = TotTax3 + TTax3;
      TotTax4 = TotTax4 + TTax4;
      TotTax5 = TotTax5 + TTax5;
      TotTax6 = TotTax6 + TTax6;
      TotTax7 = TotTax7 + TTax7;
      TotTax8 = TotTax8 + TTax8;
      TotTax9 = TotTax9 + TTax9;
      TTax = 0.0;
      TTax0 = 0.0;
      TTax1 = 0.0;
      TTax2 = 0.0;
      TTax3 = 0.0;
      TTax4 = 0.0;
      TTax5 = 0.0;
      TTax6 = 0.0;
      TTax7 = 0.0;
      TTax8 = 0.0;
      TTax9 = 0.0;

      TotSub0 = TotSub0 + TSub0;
      TotSub1 = TotSub1 + TSub1;
      TotSub2 = TotSub2 + TSub2;
      TotSub3 = TotSub3 + TSub3;
      TotSub4 = TotSub4 + TSub4;
      TotSub5 = TotSub5 + TSub5;
      TotSub6 = TotSub6 + TSub6;
      TotSub7 = TotSub7 + TSub7;
      TotSub8 = TotSub8 + TSub8;
      TotSub9 = TotSub9 + TSub9;
      TSub0 = 0.0;
      TSub1 = 0.0;
      TSub2 = 0.0;
      TSub3 = 0.0;
      TSub4 = 0.0;
      TSub5 = 0.0;
      TSub6 = 0.0;
      TSub7 = 0.0;
      TSub8 = 0.0;
      TSub9 = 0.0;
    }

    TTax0 = (TotTax0 * 100) / 100;
    TTax1 = (TotTax1 * 100) / 100;
    TTax2 = (TotTax2 * 100) / 100;
    TTax3 = (TotTax3 * 100) / 100;
    TTax4 = (TotTax4 * 100) / 100;
    TTax5 = (TotTax5 * 100) / 100;
    TTax6 = (TotTax6 * 100) / 100;
    TTax7 = (TotTax7 * 100) / 100;
    TTax8 = (TotTax8 * 100) / 100;
    TTax9 = (TotTax9 * 100) / 100;

    final List<double> datatax = <double>[
      TTax0,
      TTax1,
      TTax2,
      TTax3,
      TTax4,
      TTax5,
      TTax6,
      TTax7,
      TTax8,
      TTax9,
      TotSub0,
      TotSub1,
      TotSub2,
      TotSub3,
      TotSub4,
      TotSub5,
      TotSub6,
      TotSub7,
      TotSub8,
      TotSub9
    ];
    return datatax;
  }

  @override
  Future<List<double>> findTax(
      int SalesNo, int SplitNo, String TableNo, int digit) async {
    final Database db = await dbHelper.database;
    double GTotal,
        BillDisc,
        TPercent,
        ItemTotal,
        ItemDisc,
        Amount,
        TaxRate,
        STax,
        Amnt,
        Disc;
    double SSub,
        TBillDisc,
        TTax = 0.0,
        TTax0 = 0.0,
        TTax1 = 0.0,
        TTax2 = 0.0,
        TTax3 = 0.0,
        TTax4 = 0.0,
        TTax5 = 0.0,
        TTax6 = 0.0,
        TTax7 = 0.0,
        TTax8 = 0.0,
        TTax9 = 0.0,
        STtl,
        STaxRate;
    double TSub0 = 0.0,
        TSub1 = 0.0,
        TSub2 = 0.0,
        TSub3 = 0.0,
        TSub4 = 0.0,
        TSub5 = 0.0,
        TSub6 = 0.0,
        TSub7 = 0.0,
        TSub8 = 0.0,
        TSub9 = 0.0;
    String strTax, TableName;
    int TaxCode;

    String query =
        'SELECT COUNT(SalesNo) FROM HeldItems WHERE SalesNo = $SalesNo AND SplitNo = $SplitNo';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    final int count = cast<int>(maps[0].entries.first.value) ?? 0;
    if (count > 0) {
      TableName = 'HeldItems';
    } else {
      TableName = 'SalesItemsTemp';
    }

    query =
        "SELECT IFNULL(SUM(ItemAmount), 0) FROM $TableName WHERE SalesNo = $SalesNo AND SplitNo = $SplitNo AND FunctionID = 25 AND ItemAmount <> 0 AND TransStatus = ' '";
    maps = await db.rawQuery(query);
    TBillDisc = dynamicToDouble(maps[0].entries.first.value);

    query =
        "SELECT IFNULL(SUM(Quantity * ItemAmount * CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END), 0), IFNULL(SUM((IFNULL(PromotionSaving, 0) + IFNULL(Discount, 0)) * (CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END)), 0) FROM $TableName WHERE SalesNo = SalesNo  AND SplitNo = SplitNo AND (TransStatus = ' ' OR TransStatus = 'D')";
    maps = await db.rawQuery(query);
    var tempData = maps[0];
    Amount = dynamicToDouble(tempData.entries.elementAt(0));
    Disc = dynamicToDouble(tempData.entries.elementAt(1));

    STtl = Amount - Disc;
    GTotal = STtl - TBillDisc;

    bool exemptable, discInc, appliesToNett, salesTax, inclusive;
    String title;

    query =
        'SELECT TaxCode, Exemptable, DiscInclusive, TaxRate, Title, AppliesToNett, SalesTax, inclusive FROM TaxRates WHERE TaxRate > 0 AND MinTaxable < ${GTotal.toString()} ORDER BY AppliesToNett DESC, TaxCode';
    maps = await db.rawQuery(query);
    for (int i = 0; i < maps.length; i++) {
      tempData = maps[i];

      TaxCode = cast<int>(tempData.entries.elementAt(0).value) ?? 0;
      exemptable =
          (cast<int>(tempData.entries.elementAt(1).value) ?? 0).toBool();
      discInc = (cast<int>(tempData.entries.elementAt(2).value) ?? 0).toBool();
      TPercent =
          double.tryParse(tempData.entries.elementAt(3).value.toString()) ??
              0.00;
      title = tempData.entries.elementAt(4).value.toString();
      appliesToNett = (tempData.entries.elementAt(5).value as int).toBool();
      salesTax = (tempData.entries.elementAt(6).value as int).toBool();
      inclusive = (tempData.entries.elementAt(7).value as int).toBool();

      strTax = 'ApplyTax$TaxCode';
      TaxRate = TPercent / 100;
      STax = 0.00;
      ItemTotal = 0.00;
      ItemDisc = 0.00;
      BillDisc = 0.00;

      query =
          "SELECT IFNULL(SUM((Quantity * ItemAmount) * (CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END)), 0), IFNULL(SUM((IFNULL(PromotionSaving,0) + IFNULL(Discount,0)) * (CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END)), 0) FROM $TableName WHERE SalesNo = $SalesNo AND SplitNo = $SplitNo  AND (TransStatus = ' ' OR TransStatus = 'D') AND $strTax  = 1";
      maps = await db.rawQuery(query);
      tempData = maps[0];
      ItemTotal = dynamicToDouble(tempData.entries.elementAt(0).value);
      ItemDisc = dynamicToDouble(tempData.entries.elementAt(1).value);

      if (ItemTotal == 0) {
        STax = 0.00;
      } else {
        String SurchargeFeature;
        double Surcharge;
        query =
            "SELECT IFNULL(Feature,' ') FROM $TableName h INNER JOIN SubFunction s ON h.FunctionID = s.FunctionID AND h.SubFunctionID = s.SubFunctionID WHERE h.SalesNo = $SalesNo AND h.SplitNo = $SplitNo AND h.FunctionID = 55 AND h.TransStatus = ' '";
        maps = await db.rawQuery(query);
        if (maps.isEmpty) {
          SurchargeFeature = ' ';
        } else {
          tempData = maps[0];
          final String text = tempData.entries.elementAt(0).value.toString();
          SurchargeFeature = text.substring(0, 1);
        }

        if (SurchargeFeature == '2') {
          query =
              "SELECT IFNULL(Discount,0) FROM  TableName  WHERE SalesNo = $SalesNo AND SplitNo = $SplitNo AND FunctionID = 55 AND TransStatus = ' '";
          maps = await db.rawQuery(query);
          tempData = maps[0];

          Surcharge = cast<double>(tempData.entries.elementAt(0).value) ?? 0.00;
          ItemTotal = ItemTotal + Surcharge;
        }

        if (TBillDisc > 0) {
          BillDisc = TBillDisc;
        }

        if (discInc) {
          Amnt = ItemTotal;
        } else {
          Amnt = ItemTotal - (ItemDisc + BillDisc);
        }

        if (appliesToNett) {
          STax = Amnt * TaxRate;
          SSub = Amnt;
        } else {
          STax = (Amnt + TTax) * TaxRate;
          SSub = (Amnt + TTax);
        }

        if (salesTax) {
          if (!inclusive) {
            STax = (TTax + Amnt) * TaxRate;
            SSub = (TTax + Amnt);
          } else {
            STaxRate = 1 + TaxRate;
            STax = (Amnt + TTax) - ((Amnt + TTax) / STaxRate);
            SSub = ((Amnt + TTax) / STaxRate);
          }
        }

        STax = (STax * 100) / 100;
        TTax = TTax + STax;

        if (TaxCode == 0) {
          TTax0 = STax;
          TSub0 = SSub;
        }

        if (TaxCode == 1) {
          TTax1 = STax;
          TSub1 = SSub;
        }

        if (TaxCode == 2) {
          TTax2 = STax;
          TSub2 = SSub;
        }

        if (TaxCode == 3) {
          TTax3 = STax;
          TSub3 = SSub;
        }

        if (TaxCode == 4) {
          TTax4 = STax;
          TSub4 = SSub;
        }

        if (TaxCode == 5) {
          TTax5 = STax;
          TSub5 = SSub;
        }

        if (TaxCode == 6) {
          TTax6 = STax;
          TSub6 = SSub;
        }

        if (TaxCode == 7) {
          TTax7 = STax;
          TSub7 = SSub;
        }

        if (TaxCode == 8) {
          TTax8 = STax;
          TSub8 = SSub;
        }

        if (TaxCode == 9) {
          TTax9 = STax;
          TSub9 = SSub;
        }
      }
    }

    final List<double> taxData = <double>[
      TTax0,
      TTax1,
      TTax2,
      TTax3,
      TTax4,
      TTax5,
      TTax6,
      TTax7,
      TTax8,
      TTax9,
      TSub0,
      TSub1,
      TSub2,
      TSub3,
      TSub4,
      TSub5,
      TSub6,
      TSub7,
      TSub8,
      TSub9
    ];

    return taxData;
  }

  @override
  Future<void> paymentItem(
      String posID,
      int operatorNo,
      String tableNo,
      int salesNo,
      int splitNo,
      int paymentType,
      double paidAmount,
      String customerID) async {
    final Database db = await dbHelper.database;
    double TTax0 = 0.0;
    double TTax1 = 0.0;
    double TTax2 = 0.0;
    double TTax3 = 0.0;
    double TTax4 = 0.0;
    double TTax5 = 0.0;
    double TTax6 = 0.0;
    double TTax7 = 0.0;
    double TTax8 = 0.0;
    double TTax9 = 0.0;
    double PdAmnt = 0.0;
    double ItemAmount = 0.0;
    double ChangeAmount = 0.0;
    double PdTotal = 0.0;

    final String sDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String sTime = DateFormat('HH:mm:ss.000').format(DateTime.now());
    String msgPayment = '';
    double msgAmount = 0.00;

    String query =
        'SELECT FunctionID, SubFunctionID, Title FROM Media WHERE SubFunctionID = $paymentType';
    var data = await db.rawQuery(query);
    var tempdata = data[0];
    final int FunctionID = dynamicToInt(tempdata.values.elementAt(0));
    final int SubFunctionID = dynamicToInt(tempdata.values.elementAt(1));
    final String nmMedia = tempdata.values.elementAt(2).toString();

    query =
        'SELECT IFNULL(MembershipId, 0), RcptNo, Covers FROM HeldTables WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    data = await db.rawQuery(query);
    if (data.isEmpty) {
      throw Exception('No Table Selected');
    }
    tempdata = data[0];
    final int MembershipId = dynamicToInt(tempdata.values.elementAt(0));
    String RcptNo = tempdata.values.elementAt(1).toString();
    final int Covers = dynamicToInt(tempdata.values.elementAt(2));

    query = 'SELECT inclusive FROM TaxRates WHERE SalesTax = 1';
    data = await db.rawQuery(query);
    tempdata = data[0];
    final bool ItemTaxInc = dynamicToBool(tempdata.values.elementAt(0));

    query =
        "SELECT TAmnt, Disc, Surcharge FROM (SELECT SUM(Quantity * ItemAmount * CASE WHEN (FunctionID = 26) AND FOCItem = 0 THEN 1 ELSE 0 END) AS TAmnt, SUM((IFNULL(Discount,0) + IFNULL(PromotionSaving,0)) * CASE WHEN FunctionID = 25 OR FunctionID = 26 AND FOCItem = 0 THEN 1 ELSE 0 END) AS Disc, SUM((IFNULL(Discount,0)) * CASE WHEN FunctionID = 55 THEN 1 ELSE 0 END) AS Surcharge FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' Or TransStatus = 'D')) AS a";
    data = await db.rawQuery(query);
    tempdata = data[0];
    final double TAmnt = dynamicToDouble(tempdata.values.elementAt(0));
    final double Disc = dynamicToDouble(tempdata.values.elementAt(1));
    final double Surcharge = dynamicToDouble(tempdata.values.elementAt(2));

    final double STotal = TAmnt;
    double GTotal = TAmnt - Disc + Surcharge;

    if (!POSDefault.TaxInclusive) {
      final List<double> TaxArr = await findTax(salesNo, splitNo, tableNo, 2);
      TTax0 = TaxArr[0];
      TTax1 = TaxArr[1];
      TTax2 = TaxArr[2];
      TTax3 = TaxArr[3];
      TTax4 = TaxArr[4];
      TTax5 = TaxArr[5];
      TTax6 = TaxArr[6];
      TTax7 = TaxArr[7];
      TTax8 = TaxArr[8];
      TTax9 = TaxArr[9];

      if (!ItemTaxInc) {
        GTotal = GTotal +
            TTax0 +
            TTax1 +
            TTax2 +
            TTax3 +
            TTax4 +
            TTax5 +
            TTax6 +
            TTax7 +
            TTax8 +
            TTax9;
      } else {
        GTotal = GTotal +
            TTax1 +
            TTax2 +
            TTax3 +
            TTax4 +
            TTax5 +
            TTax6 +
            TTax7 +
            TTax8 +
            TTax9;
      }
    } else {
      final List<double> TaxArr =
          await findExTax(salesNo, splitNo, tableNo, 2, false);

      TTax0 = TaxArr[0];
      TTax1 = TaxArr[1];
      TTax2 = TaxArr[2];
      TTax3 = TaxArr[3];
      TTax4 = TaxArr[4];
      TTax5 = TaxArr[5];
      TTax6 = TaxArr[6];
      TTax7 = TaxArr[7];
      TTax8 = TaxArr[8];
      TTax9 = TaxArr[9];
    }

    query =
        'SELECT COUNT(OperatorNo) FROM OperatorMedia WHERE OperatorNo = $operatorNo AND MediaID = $SubFunctionID';
    final int CountOperator = await countData(query);

    if (CountOperator <= 0) {
      GlobalConfig.ErrMsg =
          'Operator does not have permission to Tender with Media \"' +
              nmMedia +
              '\"';
      return;
    } else {
      query =
          "SELECT IFNULL(SUM(ItemAmount), 0) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TransStatus = ' ' AND FunctionID IN (1,2,3,4,5,6,7,8,9)";
      data = await db.rawQuery(query);
      tempdata = data[0];
      PdTotal = dynamicToDouble(tempdata.values.elementAt(0));
      if (GlobalConfig.ErrMsg == '') {
        //fully paid
        if ((GTotal - PdTotal) == paidAmount) {
          msgPayment = 'Paid';
          msgAmount = 0.0;
          ItemAmount = paidAmount;
          ChangeAmount = 0.0;
        }

        //partially paid
        if ((GTotal - PdTotal) > paidAmount) {
          msgPayment = 'Remaining';
          msgAmount = (GTotal - PdTotal) - paidAmount;
          ItemAmount = paidAmount;
          ChangeAmount = 0.0;
        }

        //fully paid with change
        if ((GTotal - PdTotal) < paidAmount) {
          msgPayment = 'Change';
          msgAmount = paidAmount - (GTotal - PdTotal);
          ItemAmount = GTotal - PdTotal;
          ChangeAmount = msgAmount;
        }

        List<String> fields = [
          'POSID',
          'OperatorNo',
          'Covers',
          'TableNo',
          'SalesNo',
          'SplitNo',
          'PLUSalesRef',
          'ItemSeqNo',
          'PLUNo',
          'Department',
          'SDate',
          'STime',
          'Quantity',
          'ItemName',
          'ItemName_Chinese',
          'ItemAmount',
          'PaidAmount',
          'ChangeAmount',
          'Gratuity',
          'Tax0',
          'Tax1',
          'Tax2',
          'Tax3',
          'Tax4',
          'Tax5',
          'Tax6',
          'Tax7',
          'Tax8',
          'Tax9',
          'DiscountType',
          'DiscountPercent',
          'Discount',
          'PromotionId',
          'PromotionType',
          'PromotionSaving',
          'TransMode',
          'RefundID',
          'TransStatus',
          'FunctionID',
          'SubFunctionID',
          'MembershipID',
          'LoyaltyCardNo',
          'CustomerID',
          'AvgCost',
          'RecipeId',
          'PriceShift',
          'CategoryId',
          'Preparation',
          'FOCItem',
          'FOCType',
          'ApplyTax0',
          'ApplyTax1',
          'ApplyTax2',
          'ApplyTax3',
          'ApplyTax4',
          'ApplyTax5',
          'ApplyTax6',
          'ApplyTax7',
          'ApplyTax8',
          'ApplyTax9',
          'LnkTo',
          'Setmenu',
          'SetMenuRef',
          'TblHold',
          'SeatNo',
          'ServerNo'
        ];
        List<dynamic> values = [
          posID,
          operatorNo.toString(),
          Covers,
          tableNo,
          salesNo.toString(),
          splitNo.toString(),
          '0',
          '101',
          "000000000000000",
          '0',
          "$sDate",
          "$sTime",
          '0',
          "$nmMedia",
          "$nmMedia",
          ItemAmount.toString(),
          paidAmount.toString(),
          ChangeAmount.toString(),
          '0',
          '0.00',
          '0.00',
          '0.00',
          '0.00',
          '0.00',
          '0.00',
          '0.00',
          '0.00',
          '0.00',
          '0.00',
          "",
          '0',
          '0.00',
          '0',
          "",
          '0.00',
          "${GlobalConfig.TransMode}",
          '0',
          " ",
          FunctionID.toString(),
          SubFunctionID.toString(),
          '${MembershipId}',
          "",
          "$customerID",
          '0.00',
          '0',
          '${POSDtls.DefPShift}',
          '${POSDtls.categoryID}',
          '0',
          '0',
          "''",
          '0',
          '0',
          '0',
          '0',
          '0',
          '0',
          '0',
          '0',
          '0',
          '0',
          "",
          '0',
          '0',
          '1',
          '0',
          '$operatorNo'
        ];
        final Map<String, dynamic> rows = <String, dynamic>{};
        for (var i = 0; i < fields.length; i++) {
          rows[fields[i]] = values[i];
        }
        await db.insert('HeldItems', rows);
        // insertData('HeldItems', fields, values);

        query =
            "SELECT MAX(SalesRef) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TransStatus = ' ' AND ItemSeqNo = 101";
        data = await db.rawQuery(query);
        tempdata = data[0];
        final int SalesRef = dynamicToInt(tempdata.values.elementAt(0));

        if ((GTotal - PdTotal) <= paidAmount) {
          fields = <String>[
            'Tax0',
            'Tax1',
            'Tax2',
            'Tax3',
            'Tax4',
            'Tax5',
            'Tax6',
            'Tax7',
            'Tax8',
            'Tax9',
            'RndingAdjustments'
          ];
          values = <dynamic>[
            TTax0,
            TTax1,
            TTax2,
            TTax3,
            TTax4,
            TTax5,
            TTax6,
            TTax7,
            TTax8,
            TTax9,
            0
          ];
          // rows = <String, dynamic>{};
          for (int i = 0; i < fields.length; i++) {
            rows[fields[i]] = values[i];
          }
          String condition = 'SalesRef = $SalesRef';
          await db.update('HeldItems', rows,
              where: 'SalesRef = ?', whereArgs: [SalesRef]);
          // updateData('HeldItems', fields, values, condition);

          query =
              "SELECT IFNULL (SUM(ItemAmount),0) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TransStatus = ' ' AND FunctionID IN (1,2,3,4,5,6,7,8,9)";
          data = await db.rawQuery(query);
          tempdata = data[0];
          PdAmnt = dynamicToDouble(tempdata.values.elementAt(0));

          final double Balance = GTotal - PdAmnt;

          fields = <String>[
            'STotal',
            'GTotal',
            'PaidAmount',
            'Balance',
            'Close_Date',
            'Close_Time'
          ];
          values = <dynamic>[STotal, GTotal, PdAmnt, Balance, sDate, sTime];

          final Map<String, dynamic> heldTableRows = <String, dynamic>{};
          for (int i = 0; i < fields.length; i++) {
            heldTableRows[fields[i]] = values[i];
          }
          condition = 'SalesNo = $salesNo AND SplitNo = $splitNo';
          await db.update('HeldTables', heldTableRows,
              where: 'SalesNo = ? AND SplitNo = ?',
              whereArgs: [salesNo, splitNo]);
          // updateData('HeldTables', fields, values, condition);

          fields = <String>[
            'POSID',
            'OperatorNo',
            'Covers',
            'TableNo',
            'SalesNo',
            'SplitNo',
            'PLUSalesRef',
            'ItemSeqNo',
            'PLUNo',
            'Department',
            'SDate',
            'STime',
            'Quantity',
            'ItemName',
            'ItemName_Chinese',
            'ItemAmount',
            'PaidAmount',
            'ChangeAmount',
            'Gratuity',
            'Tax0',
            'Tax1',
            'Tax2',
            'Tax3',
            'Tax4',
            'Tax5',
            'Tax6',
            'Tax7',
            'Tax8',
            'Tax9',
            'DiscountType',
            'DiscountPercent',
            'Discount',
            'PromotionId',
            'PromotionType',
            'PromotionSaving',
            'TransMode',
            'RefundID',
            'TransStatus',
            'FunctionID',
            'SubFunctionID',
            'MembershipID',
            'LoyaltyCardNo',
            'CustomerID',
            'AvgCost',
            'RecipeId',
            'PriceShift',
            'CategoryId',
            'Preparation',
            'FOCItem',
            'FOCType',
            'ApplyTax0',
            'ApplyTax1',
            'ApplyTax2',
            'ApplyTax3',
            'ApplyTax4',
            'ApplyTax5',
            'ApplyTax6',
            'ApplyTax7',
            'ApplyTax8',
            'ApplyTax9',
            'LnkTo',
            'Setmenu',
            'SetMenuRef',
            'TblHold',
            'SeatNo',
            'ServerNo'
          ];
          values = <String>[
            posID,
            operatorNo.toString(),
            Covers.toString(),
            tableNo,
            salesNo.toString(),
            splitNo.toString(),
            '0',
            '102',
            "000000000000000",
            '0',
            sDate,
            sTime,
            '0',
            "CLOSE",
            "CLOSE",
            ItemAmount.toString(),
            paidAmount.toString(),
            ChangeAmount.toString(),
            '0',
            '0.00',
            '0.00',
            '0.00',
            '0.00',
            '0.00',
            '0.00',
            '0.00',
            '0.00',
            '0.00',
            '0.00',
            "",
            '0',
            '0.00',
            '0',
            "",
            '0.00',
            GlobalConfig.TransMode,
            '0',
            "S",
            FunctionID.toString(),
            SubFunctionID.toString(),
            MembershipId.toString(),
            "",
            "$customerID",
            '0.00',
            '0',
            POSDtls.DefPShift.toString(),
            POSDtls.categoryID.toString(),
            '0',
            '0',
            "",
            '0',
            '0',
            '0',
            '0',
            '0',
            '0',
            '0',
            '0',
            '0',
            '0',
            "",
            '0',
            '0',
            '1',
            '0',
            operatorNo.toString()
          ];
          // rows = <String, String>{};
          for (var i = 0; i < fields.length; i++) {
            rows[fields[i]] = values[i];
          }
          await db.insert('HeldItems', rows);
          // insertData('HeldItems', fields, values);

          if (RcptNo.isNotEmpty) {
            query =
                'SELECT COUNT(RcptNo), RcptNo FROM HeldTables WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
            data = await db.rawQuery(query);
            tempdata = data[0];
            final int CountRcpt = dynamicToInt(tempdata.values.elementAt(0));

            if (CountRcpt > 0) {
              RcptNo = tempdata.values.elementAt(1).toString();
            } else {
              GlobalConfig.ErrMsg = 'Receipt Number Not Found';
              return;
            }

            if (RcptNo == ' 000000000000') {
              GlobalConfig.ErrMsg = 'Generate Receipt Number Failed';
              return;
            }

            if (GlobalConfig.ErrMsg == '') {
              fields = <String>[
                'ReceiptNo',
                'OperatorNo',
                'TableNo',
                'SalesNo',
                'SplitNo',
                'Finalized',
                'Printed',
                'Void',
                'TaxExempt',
                'CopyNo'
              ];
              values = <String>[
                "$RcptNo",
                operatorNo.toString(),
                "$tableNo",
                salesNo.toString(),
                splitNo.toString(),
                '1',
                '0',
                '0',
                '0',
                '0'
              ];
              final Map<String, String> maps = <String, String>{
                'ReceiptNo': "$RcptNo",
                'OperatorNo': operatorNo.toString(),
                'TableNo': "$tableNo",
                'SalesNo': salesNo.toString(),
                'SplitNo': splitNo.toString(),
                'Finalized': '1',
                'Printed': '0',
                'Void': '0',
                'TaxExempt': '0',
                'CopyNo': '0',
              };
              await db.insert('RcptDtls', maps);
              // insertData('RcptDtls', fields, values);
            }
          }

          if (GlobalConfig.ErrMsg == '') {
            fields = <String>[
              'OperatorNo',
              'TableNo',
              'Finalized',
              'PrintDate',
              'PrintTime'
            ];
            values = <String>[
              operatorNo.toString(),
              tableNo,
              '1',
              sDate,
              sTime
            ];
            final Map<String, String> maps = <String, String>{
              'OperatorNo': operatorNo.toString(),
              'TableNo': tableNo,
              'Finalized': '1',
              'PrintDate': sDate,
              'PrintTime': sTime,
            };
            condition = "ReceiptNo = '$RcptNo'";
            await db.update('RcptDtls', maps,
                where: 'ReceiptNo = ?', whereArgs: [RcptNo]);
            // updateData('RcptDtls', fields, values, condition);

            await moveSales(salesNo, splitNo);
            await moveSales2(salesNo, splitNo);
            await moveSales3(salesNo, splitNo);

            if (tableNo != '') {
              query =
                  "SELECT COUNT(TableNo) FROM HeldTables WHERE TableNo = '$tableNo'";
              final int CountTbl = await countData(query);

              if (CountTbl < 1) {
                fields = <String>['TBLStatus'];
                values = <String>["'A'"];
                condition = "TBLNo = '$tableNo'";
                await db.update('TblLayout', {'TBLStatus': 'A'},
                    where: "TBLNo = ?", whereArgs: [tableNo]);
                // updateData('TblLayout', fields, values, condition);
              } else {
                fields = <String>['TBLStatus'];
                values = <String>["'O'"];
                condition =
                    "TBLNo IN (SELECT TableNo FROM HeldTables WHERE TableNo ='$tableNo')";
                await db.update('TblLayout', {'TBLStatus': '0'},
                    where:
                        'TBLNo IN (SELECT TableNo FROM HeldTables WHERE TableNo = ? )',
                    whereArgs: [tableNo]);
                // updateData('TblLayout', fields, values, condition);
              }
            }

            if (POSDefault.GenerateReceiptNoEnd) {
              // await db.rawDelete(
              // "DELETE FROM RcptNoCtrlEndTemp WHERE SalesNo = $salesNo AND SplitNo = $splitNo");
            }
          }
        }
      }
    }
  }

  @override
  Future<String> getBillFOCName(int salesNo) async {
    final Database dbHandler = await dbHelper.database;

    final String query =
        "SELECT ItemName FROM SalesItemsTemp WHERE SalesNo = $salesNo AND ItemSeqNo = 101 AND FunctionID NOT IN (25, 33) AND TransStatus = ' '";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    final Map<String, dynamic> tempData = data[0];

    final String itemName = tempData.values.first.toString();
    return itemName;
  }

  @override
  Future<List<Map<String, dynamic>>> getData(String query) async {
    final Database db = await dbHelper.database;
    final List<Map<String, dynamic>> response = await db.rawQuery(query);
    return response;
  }

  @override
  Future<List<bool>> getFOCBillProperty(int subFuncID) async {
    final Database dbHandler = await dbHelper.database;

    final String query =
        'SELECT VerifyFOC, Remarks, PromptForCustomerId, AllowPromotion FROM Media WHERE SubFunctionID = $subFuncID';
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    if (data.isNotEmpty) {
      final Map<String, dynamic> tempData = data[0];
      final List<bool> boolData = <bool>[];
      boolData.add(dynamicToBool(tempData.values.first));
      boolData.add(dynamicToBool(tempData.values.elementAt(1)));
      boolData.add(dynamicToBool(tempData.values.elementAt(2)));
      boolData.add(dynamicToBool(tempData.values.elementAt(3)));
      return boolData;
    }
    return <bool>[];
  }

  @override
  Future<List<FocBillData>> getFocBillData() async {
    final Database dbHandler = await dbHelper.database;

    final List<FocBillData> focBillList = <FocBillData>[];
    const String query =
        'SELECT Title, SubFunctionID FROM Media WHERE FunctionID = 7 AND MActive = 1 ORDER BY Title';
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    focBillList.add(FocBillData(title: 'Back', subFuncID: 0));
    Map<String, dynamic> tempData;

    for (tempData in data) {
      focBillList.add(FocBillData(
          title: tempData.values.first.toString(),
          subFuncID: dynamicToInt(tempData.values.elementAt(1))));
    }

    return focBillList;
  }

  @override
  Future<List<MediaData>> getMediaByType(int funcID, int operatorNo) async {
    final Database dbHandler = await dbHelper.database;

    final List<MediaData> mediaList = <MediaData>[];
    final String query =
        'SELECT FunctionID, Title, Title_Chinese, SubFunctionID, TenderValue, Minimum, Maximum, PromptForCustomerID, PrintSignature, ApplyTax FROM Media m INNER JOIN OperatorMedia om ON m.SubFunctionID = om.MediaID WHERE MActive = 1 AND FunctionID = $funcID AND om.OperatorNo = $operatorNo ORDER BY SortNo, Title, FunctionID';

    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    mediaList.add(MediaData(
        funcID: 0,
        title: 'Back',
        titleChinese: 'Back',
        subFuncID: 0,
        applyTax: false,
        maximum: 0,
        minimum: 0,
        printSignature: false,
        propForCustID: false,
        tenderValue: 0.00));

    Map<String, dynamic> tempData;
    for (tempData in data) {
      mediaList.add(MediaData(
        funcID: dynamicToInt(tempData.values.first),
        title: tempData.values.elementAt(1).toString(),
        titleChinese: tempData.values.elementAt(2).toString(),
        subFuncID: dynamicToInt(tempData.values.elementAt(3)),
        tenderValue: dynamicToDouble(tempData.values.elementAt(4)),
        minimum: dynamicToDouble(tempData.values.elementAt(5)),
        maximum: dynamicToDouble(tempData.values.elementAt(6)),
        propForCustID: dynamicToBool(tempData.values.elementAt(7)),
        printSignature: dynamicToBool(tempData.values.elementAt(8)),
        applyTax: dynamicToBool(tempData.values.elementAt(9)),
      ));
    }
    return mediaList;
  }

  @override
  Future<List<MediaData>> getMediaType() async {
    final Database dbHandler = await dbHelper.database;

    final List<MediaData> mediaList = <MediaData>[];
    const String query =
        'SELECT FunctionId, Type, Type_Chinese FROM Functions WHERE Class = 1 AND FunctionID IN (1, 2, 4)';
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    Map<String, dynamic> tempData;
    for (tempData in data) {
      mediaList.add(MediaData(
          funcID: dynamicToInt(tempData.values.first),
          title: tempData.values.elementAt(1).toString(),
          titleChinese: tempData.values.elementAt(2).toString(),
          subFuncID: 0,
          applyTax: false,
          maximum: 0,
          minimum: 0,
          printSignature: false,
          propForCustID: false,
          tenderValue: 0));
    }
    return mediaList;
  }

  @override
  Future<List<Map<String, dynamic>>> getOrderStatusBySNo(int salesNo) async {
    final Database db = await dbHelper.database;
    final String query =
        'SELECT TableNo, SplitNo, Covers, RcptNo FROM HeldTables WHERE SalesNo = $salesNo';
    final List<Map<String, dynamic>> data = await db.rawQuery(query);
    return data;
  }

  @override
  Future<double> getPaidAmount(int salesNo, int splitNo, String tableNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT IFNULL(SUM(ItemAmount), 0) FROM HeldItems WHERE TransStatus = ' ' AND SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo' AND FunctionID IN (1,2,3,4,5,7,8,9)";

    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    final Map<String, dynamic> tempData = data[0];

    final double paidAmount = dynamicToDouble(tempData.values.first);

    return paidAmount;
  }

  @override
  Future<List<PaymentDetailsData>> getPaymentDetails(
      int salesNo, int splitNo, String tableNo) async {
    final Database dbHandler = await dbHelper.database;

    final List<PaymentDetailsData> paymentDetailsList = <PaymentDetailsData>[];
    final String query =
        "SELECT ItemName, ItemAmount, SalesRef FROM HeldItems WHERE ItemSeqNo = 101 AND SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo' AND TransStatus = ' ' AND FunctionID IN (1, 2, 3, 4, 5, 7, 8, 9) ORDER BY SalesRef";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    Map<String, dynamic> tempData;

    for (tempData in data) {
      paymentDetailsList.add(PaymentDetailsData(
          name: tempData.values.first.toString(),
          amount: dynamicToDouble(tempData.values.elementAt(1)),
          salesRef: dynamicToInt(tempData.values.elementAt(2))));
    }

    return paymentDetailsList;
  }

  /// SUM(PaidAmount), ChangeAmount, SUM(ItemAmount)
  @override
  Future<Map<String, dynamic>> getPopUpAmount(int salesNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT SUM(PaidAmount), ChangeAmount, SUM(ItemAmount) FROM SalesItemsTemp WHERE SalesNo = $salesNo AND ItemSeqNo = 101 AND FunctionID NOT IN (25, 33) AND TransStatus = ' '";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    final Map<String, dynamic> tempData = data[0];
    return tempData;
  }

  @override
  Future<List<List<String>>> getPrintBillDisc(int sNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        'SELECT ItemName, SUM(Discount) as discount FROM SalesItemsTemp WHERE SalesNo = $sNo AND FunctionID = 25 GROUP BY Discount';
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<List<List<String>>> getPrintCategory(int sNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        'SELECT DISTINCT SC.CategoryName, SC.CategoryID FROM SalesItemsTemp S INNER JOIN SalesCategory SC ON (S.CategoryId = SC.CategoryID) WHERE S.SalesNo = $sNo ORDER BY SC.CategoryName';
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<List<List<String>>> getPrintItem(int sNo, String ctgName) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT Quantity, ItemName, ((ItemAmount * Quantity) - (CASE WHEN FOCItem = 1 THEN IFNULL(Discount,0) ELSE 0 END)), Preparation, IFNULL(DiscountType,''), IFNULL(Discount,0), IFNULL(PromotionType,''), IFNULL(PromotionSaving,0) FROM SalesItemsTemp S INNER JOIN SalesCategory SC ON (S.CategoryId = SC.CategoryID) WHERE SalesNo = $sNo AND ItemSeqNo NOT IN (101,102) AND FunctionID NOT IN (24,25,33) AND SC.CategoryName = '$ctgName' AND ((TransStatus = ' ' OR TransStatus = 'D') OR (TransStatus = 'N' AND SubFunctionID = 2)) ORDER BY PLUSalesRef, SalesRef";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<List<List<String>>> getPrintPayment(int sNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT ItemName, PaidAmount, ChangeAmount FROM SalesItemsTemp WHERE SalesNo = $sNo AND (ItemSeqNo = 101 OR (ItemSeqNo = 102 AND FunctionID = 32)) AND FunctionID NOT IN (25,33) AND TransStatus = ' '";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<List<List<String>>> getPrintPromo(int sNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT PromotionType, SUM(PromotionSaving) FROM SalesItemsTemp WHERE SalesNo = $sNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FOCType <> 'FOC Item' GROUP BY PromotionType HAVING SUM(PromotionSaving) <> 0";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<List<List<String>>> getPrintRefund(int sNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        'SELECT * FROM AutoRfndBill WHERE salesno = $sNo OR RfndSalesno = $sNo';
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<List<List<String>>> getPrintTax(int sNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT SUM(Tax0), SUM(Tax1), SUM(Tax2), SUM(Tax3), SUM(Tax4), SUM(Tax5), SUM(Tax6), SUM(Tax7), SUM(Tax8), SUM(Tax9) FROM SalesItemsTemp WHERE SalesNo = $sNo AND FunctionID IN (1,2,3,4,5,6,7,8,9) AND TransStatus = ' '";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<List<List<String>>> getPrintTotal(int sNo) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        'SELECT STotal, GTotal, Covers, Rcptno, TableNo FROM SalesTblsTemp WHERE SalesNo = $sNo';
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  /// TaxCode, Title, PrintTax, TaxRate
  @override
  Future<List<Map<String, dynamic>>> getTaxRateData() async {
    final Database db = await dbHelper.database;
    const String query =
        'SELECT TaxCode, Title, PrintTax, TaxRate FROM TaxRates WHERE TaxRate > 0 AND PrintTax = 1 ORDER BY appliestonett DESC, TaxCode';
    final List<Map<String, dynamic>> data = await db.rawQuery(query);
    return data;
  }

  @override
  Future<List<List<String>>> getTotalItemQty(int sNO) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT COUNT(ItemName), SUM(Qty) FROM (SELECT ItemName, SUM (Quantity) AS Qty FROM SalesItemsTemp WHERE SalesNo = $sNO AND ItemSeqNo NOT IN (101,102) AND ItemName <> 'FOC Item' AND ((TransStatus = ' ' OR TransStatus = 'D') OR (TransStatus = 'N' AND SubFunctionID = 2)) AND Preparation = 0 GROUP BY ItemName)";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return data.map((Map<String, dynamic> e) {
      return e.values.map((dynamic v) => v.toString()).toList();
    }).toList();
  }

  @override
  Future<double> getTotalRemoveAmount(
      int salesNo, int splitNo, String tableNo, int salesRef) async {
    final Database dbHandler = await dbHelper.database;
    final String query =
        "SELECT ItemAmount FROM HeldItems WHERE ItemSeqNo = 101 AND SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo' AND SalesRef = $salesRef";
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    double totalRemove = 0;

    if (data.isNotEmpty) {
      final Map<String, dynamic> tempData = data[0];
      totalRemove = cast<double>(tempData.values.first) ?? 0;
    }
    return totalRemove;
  }

  @override
  Future<void> insertFOCComments(
      int salesNo, int operatorFOC, int splitNo, String comments) async {
    final Database dbHandler = await dbHelper.database;
    String query =
        'INSERT INTO FOCComments(SalesNo, Comments, OperatorFOC, SplitNo)';
    final String values =
        " VALUES ( $salesNo, '$comments', $operatorFOC, $splitNo)";
    query += values;
    await dbHandler.rawQuery(query);
  }

  @override
  Future<void> moveSales(int salesNo, int splitNo) async {
    final Database db = await dbHelper.database;
    String query =
        "UPDATE HeldItems SET SalesAreaID = '${POSDtls.strSalesAreaID}', BusinessDate = '${POSDefault.StrBusinessDate}' WHERE SalesNo = $salesNo AND SplitNo = $splitNo";
    db.rawQuery(query);

    query =
        "UPDATE HeldTables SET SalesAreaID = '${POSDtls.strSalesAreaID}', BusinessDate = '${POSDefault.StrBusinessDate}', TransStatus = '' WHERE SalesNo = $salesNo AND SplitNo = $splitNo";
    db.rawQuery(query);

    query =
        "UPDATE RcptDtls SET SalesAreaID = '${POSDtls.strSalesAreaID}', BusinessDate = '${POSDefault.StrBusinessDate}' WHERE SalesNo = $salesNo AND SplitNo = $splitNo";
    db.rawQuery(query);
  }

  @override
  Future<void> moveSales2(int salesNo, int splitNo) async {
    final Database db = await dbHelper.database;
    String query =
        'INSERT INTO SalesTblsTemp (POSID, SalesNo, SplitNo, LastSplit, OperatorNo, TableNo, Covers, TransMode, TransStatus, MembershipID, LoyaltyCardNo, PromotionId, Open_Date, Open_Time, Close_Date, Close_Time, STotal, GTotal, PaidAmount, Balance, RsvtnID, PrntStatus, Rcptno, SalesAreaID, BusinessDate, OperatornoFirst, OperatorFOC, tblCardNo, Remarks, BalancePoints, Balances, BonusValue, DepositValue, RemarksLine, ExemptVAT) SELECT * FROM HeldTables WHERE HeldTables.SalesNo = $salesNo AND HeldTables.SplitNo = $splitNo';
    db.rawQuery(query);

    query =
        'INSERT INTO SalesItemsTemp SELECT * FROM HeldItems WHERE HeldItems.SalesNo = $salesNo AND HeldItems.SplitNo = $splitNo';
    db.rawQuery(query);

    query =
        'DELETE FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    db.rawQuery(query);

    query =
        'DELETE FROM HeldTables WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    db.rawQuery(query);
  }

  @override
  Future<void> moveSales3(int salesNo, int splitNo) async {
    final Database db = await dbHelper.database;
    String query =
        'INSERT INTO CheckKPStatus SELECT * FROM KPStatus WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    db.rawQuery(query);

    query =
        'DELETE FROM KPStatus WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    db.rawQuery(query);
  }

  // Bill Preview

  @override
  Future<bool> previewBillPermission(int operatorNo) async {
    final String query =
        'SELECT PreviewBill FROM Operator WHERE OperatorNo = $operatorNo';

    final Database database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    final bool getPermission = dynamicToBool(data[0].get(0));

    return getPermission;
  }

  @override
  Future<List<List<String>>> getSalesCatData(int salesNo) async {
    final String query =
        'SELECT DISTINCT SC.CategoryName, SC.CategoryID FROM HeldItems H INNER JOIN SalesCategory SC ON (H.CategoryID = SC.CategoryID) WHERE H.SalesNo = $salesNo ORDER BY SC.CategoryName';
    final Database database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);

    return mapListToString2D(data);
  }

  @override
  Future<List<List<String>>> getPaymentData(int salesNo) async {
    final String query =
        'SELECT ItemName, PaidAmount, ChangeAmount, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9 FROM HeldItems WHERE SalesNo = $salesNo AND ItemSeqNo = 101 AND FunctionID NOT IN (25, 33)';
    final Database database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);

    return mapListToString2D(data);
  }

  @override
  Future<List<String>> getTotalItem(int salesNo) async {
    final String query =
        "SELECT COUNT(ItemName), IFNULL(SUM(Qty),0) FROM (SELECT ItemName, SUM(Quantity) AS Qty FROM HeldItems WHERE SalesNo = $salesNo AND ItemSeqNo NOT IN (101,102) AND ItemName <> 'FOC Item' AND (TransStatus = ' ' OR TransStatus = 'D') AND Preparation = 0 GROUP BY ItemName)";
    final Database database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    final Map<String, dynamic> tempData = data[0];

    return mapToStringList(tempData);
  }

  @override
  Future<List<List<String>>> getItemData(
      int salesNo, String categoryName) async {
    final String query =
        "SELECT Quantity, ItemName, ((ItemAmount * Quantity) - (CASE WHEN FOCItem = 1 THEN IFNULL(Discount,0) ELSE 0 END)), Preparation, IFNULL(DiscountType,''), IFNULL(Discount,0), IFNULL(PromotionType,''), IFNULL(PromotionSaving,0) FROM HeldItems HI INNER JOIN SalesCategory SC ON (HI.CategoryId = SC.CategoryID) WHERE SalesNo = $salesNo AND ItemSeqNo NOT IN (101, 102) AND FunctionID NOT IN (24, 25, 33) AND SC.CategoryName = '$categoryName' AND (TransStatus = ' ' OR TransStatus = 'D') AND FOCItem = 0 ORDER BY PLUSalesRef, SalesRef";
    final Database database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);

    return mapListToString2D(data);
  }

  @override
  Future<List<List<String>>> getPromotionData(int salesNo) async {
    final String query =
        "SELECT PromotionType, SUM(PromotionSaving) FROM HeldItems WHERE SalesNo = $salesNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FOCType <> 'FOC Item' GROUP BY PromotionType HAVING SUM(PromotionSaving) <> 0";
    final Database database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);

    return mapListToString2D(data);
  }

  @override
  Future<List<String>> getTaxTitle() async {
    const String query =
        'SELECT TaxCode, Title, PrintTax, TaxRate FROM TaxRates WHERE (TaxRate > 0) AND (PrintTax = 1) ORDER BY appliestonett DESC, TaxCode';
    final Database database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    final Map<String, dynamic> tempData = data[0];

    return mapToStringList(tempData);
  }
}
