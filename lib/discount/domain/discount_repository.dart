import 'package:injectable/injectable.dart';
import 'package:raptorpos/discount/model/discount_model.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../common/helper/db_helper.dart';
import '../../common/utils/type_util.dart';

@Injectable()
class DiscountRepository with TypeUtil {
  DiscountRepository({required this.dbHelper});

  final LocalDBHelper dbHelper;

  Future<bool> CheckDiscBill(int SalesNo, int SplitNo) async {
    String query =
        'SELECT COUNT(*) FROM HeldItems WHERE FunctionID = 25 AND TransStatus = " " AND SalesNo = $SalesNo AND SplitNo = $SplitNo';

    Database database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    bool isDiscBill = false;

    if (dynamicToInt(data[0].get(0)) > 0) {
      isDiscBill = true;
    }
    return isDiscBill;
  }

  // Get All Discounts
  Future<List<DiscountModel>> getDiscs() async {
    Database db = await dbHelper.database;
    const String query =
        'SELECT Title, FunctionID, SubFunctionID, Feature, Parameter, disc_remarks, CoverBased, CoverBasedType, RGBColour FROM SubFunction WHERE FunctionID IN (24, 25) AND FActive = 1 ORDER BY Title COLLATE NOCASE';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) => DiscountModel.fromJson(e)).toList();
  }

  // Count Discount
  Future<int> countDiscByID(int discCode) async {
    Database db = await dbHelper.database;

    String query =
        'SELECT COUNT(SubFunctionID) From SubFunction Where SubFunctionID=$discCode';
    final List<Map<String, dynamic>> data = await db.rawQuery(query);
    if (data.isEmpty) {
      throw Exception('Invalid Discount! Cannot find the selected discount');
    }
    return data.length;
  }

  //
  Future<DiscountModel> getDiscByDiscCode(int discCode) async {
    final String query =
        "SELECT Title, FunctionID, SubFunctionID, Feature, Parameter, disc_remarks, CoverBased, CoverBasedType From SubFunction Where SubFunctionID = $discCode";

    final Database database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return DiscountModel.fromJson(data[0]);
  }

  ///
  Future<List<String>> getOperatorByID(int operatorNo) async {
    final query =
        "Select DiscItemAmt, DiscItemPer, DiscTotalAmt, DiscTotalPer From Operator Where OperatorNo=$operatorNo";

    final database = await dbHelper.database;
    List<Map<String, dynamic>> data = await database.rawQuery(query);
    return mapListToString2D(data)[0];
  }

  //
  Future<int> countDiscID(int operatorNo, int subFnID) async {
    final String query =
        'SELECT COUNT(DiscID) FROM operatorDISC WHERE OperatorNo=$operatorNo AND DISCid=$subFnID';

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return data.length;
  }

  // set inCoverbased
  Future<int> countCoverbasedType(
      String coverBasedType, int salesNo, int splitNo) async {
    final String query =
        "SELECT $coverBasedType FROM tbl_covertracking WHERE salesno=$salesNo AND splitno=$splitNo";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return mapListToInt2D(data)[0][0];
  }

  //
  Future<int> countSalesRef1(int salesNo, int splitNo) async {
    final String query =
        "SELECT COUNT(SalesRef) From HeldItems Where SalesNo=$salesNo AND SplitNo=$splitNo";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    if (data.isNotEmpty) {
      return dynamicToInt(data[0].get(0));
    }
    return 0;
  }

  //
  Future<int> countSalesRef2(int salesNo, int splitNo, int salesRef) async {
    final String query =
        "Select Count(SalesRef) From HeldItems Where SalesNo=$salesNo AND SplitNo=$splitNo AND TransStatus = ' ' AND FunctionID=25";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    if (data.isNotEmpty) {
      return dynamicToInt(data[0].get(0));
    }
    return 0;
  }

  //
  Future<int> countSalesRef3(int salesNo, int splitNo, int salesRef) async {
    final String query =
        "SELECT COUNT(SalesRef) From HeldItems Where SalesNo=$salesNo AND SplitNo=$splitNo AND (TransStatus=' ' or TransStatus='D') AND FunctionID=26 AND SalesRef=$salesRef";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    if (data.isNotEmpty) {
      return dynamicToInt(data[0].get(0));
    }
    return 0;
  }

  /// SalesNo, SplitNo, TransStatus, PLUSalesRef, FunctionID = 24
  Future<int> countSalesRef4(int salesNo, int splitNo, int salesRef) async {
    final String query =
        "SELECT COUNT(SalesRef) From HeldItems Where SalesNo=$salesNo AND SplitNo=$splitNo AND (TransStatus=' ' or TransStatus='D') AND FunctionID=24 AND PLUSalesRef=$salesRef";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    if (data.isNotEmpty) {
      return dynamicToInt(data[0].get(0));
    }
    return 0;
  }

  /// SalesNo, SplitNo, TransStatus, SalesRef, PromotionSaving
  Future<int> countSalesRef5(int salesNo, int splitNo, int salesRef) async {
    final String query =
        "SELECT COUNT(SalesRef) From HeldItems Where SalesNo=$salesNo AND SplitNo=$splitNo AND (TransStatus=' ' or TransStatus='D') AND PromotionSaving>0 AND SalesRef=$salesRef";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    if (data.isNotEmpty) {
      return dynamicToInt(data[0].get(0));
    }
    return 0;
  }

  /// SalesNo, SplitNo, SalesRef, RentalItem, RentToDate
  Future<int> countSalesRef6(int salesNo, int splitNo, int salesRef) async {
    final String query =
        'Select Count(SalesRef) From HeldItems Where SalesNo=$salesNo And SplitNo=$splitNo And SalesRef=$salesRef And RentalItem=1 And strftime(RentToDate) IS NULL';

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    if (data.isNotEmpty) {
      return dynamicToInt(data[0].get(0));
    }
    return 0;
  }

  /// SalesNo, SplitNo, SalesRef, RentalItem, RentToDate
  Future<int> countSalesRef7(int salesNo, int splitNo, int salesRef) async {
    final String query =
        "Select Count(SalesRef) From HeldItems Where Salesno=$salesNo And SplitNo=$splitNo And TransStatus = ' ' And FunctionID in (25)";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    if (data.isNotEmpty) {
      return dynamicToInt(data[0].get(0));
    }
    return 0;
  }

  /// SalesNo, SplitNo, SalesRef, RentalItem, RentToDate
  Future<int> countSalesRef8(int salesNo, int splitNo, int salesRef) async {
    final String query =
        "Select Count(SalesRef) From HeldItems Where SalesNo=$salesNo And SplitNo=$splitNo And RentalItem=1 And TransStatus=' ' And strftime(RentToDate) IS NULL";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    if (data.isNotEmpty) {
      return dynamicToInt(data[0].get(0));
    }
    return 0;
  }

  /// SalesNo, SplitNo, SalesRef, RentalItem, RentToDate
  Future<int> countSalesRef9(int salesNo, int splitNo, int salesRef) async {
    final String query =
        "Select Count(SalesRef) From HeldItems Where SalesNo=$salesNo And Splitno=$splitNo And TransStatus=' ' And PromotionSaving>0";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    if (data.isNotEmpty) {
      return dynamicToInt(data[0].get(0));
    }
    return 0;
  }

  /// SalesNo, SplitNo, SalesRef, RentalItem, RentToDate
  Future<int> countSalesRef10(int salesNo, int splitNo, int salesRef) async {
    final String query =
        "Select Count(SalesRef) From HeldItems Inner Join PLU On PLU.PluNumber=HeldItems.PLUNo Where SalesNo=$salesNo And SplitNo=$splitNo And TransStatus=' ' And PluDiscEntitle=1";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    if (data.isNotEmpty) {
      return dynamicToInt(data[0].get(0));
    }
    return 0;
  }

  /// SalesNo, SplitNo, SalesRef, RentalItem, RentToDate
  Future<int> countSalesRef11(int salesNo, int splitNo, int subFnID) async {
    final String query =
        "Select Count(SalesRef) From HeldItems Inner Join PLUDisc On PLUDisc.PluNumber=HeldItems.PLUNo Inner Join PLU On PLU.PluNumber=HeldItems.PLUNo Where SalesNo=$salesNo And SplitNo=$splitNo And TransStatus=' ' And PluDiscEntitle=1 And DISCid=$subFnID";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    if (data.isNotEmpty) {
      return dynamicToInt(data[0].get(0));
    }
    return 0;
  }

  // get PLUNo, PLUName
  Future<List<String>> getPLU(int salesNo, int splitNo, int salesRef) async {
    final String query =
        "SELECT PLUNo, ItemName From HeldItems Where SalesNo=$salesNo AND SplitNo=$splitNo AND FunctionID=26 AND SalesRef=$salesRef";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return mapListToString2D(data)[0];
  }

  /// Count PLUNumber Discount Allowed
  /// Where AllowDiscount is 1
  Future<int> countPLUDiscountAllowed(String pluNo) async {
    final String query =
        "SELECT COUNT(PLUNumber) From PLU Where PLUNumber='$pluNo' AND AllowDiscount=1";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return data.length;
  }

  /// Count PLUNumber where pludiscentitle = 1
  Future<int> countPLUDiscentitle(String pluNo) async {
    final String query =
        "SELECT COUNT(PLUNumber) From PLU Where PLUNumber='$pluNo' AND pludiscentitle=1";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return data.length;
  }

  /// Count pluDISC by PLUNumber AND DISCid
  Future<int> countpluDisc(String pluNo, int subFnID) async {
    final String query =
        "SELECT COUNT(PLUNumber) From pluDisc Where PLUNumber='$pluNo' AND DISCid=$subFnID";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return data.length;
  }

  /// Calc Item Amount
  Future<double> calcItemAmt(int salesNo, int splitNo, int salesRef) async {
    final String query =
        "Select IFNULL(Quantity * ItemAmount, 0) From HeldItems Where SalesNo=$salesNo And SplitNo=$splitNo And SalesRef=$salesRef And FunctionID IN (26) And FOCType NOT IN ('FOC Item', 'BuyXfreeY') AND (TransStatus=' ' Or TransStatus='D' Or TransStatus='M')";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    final Map<String, dynamic> itemAmtMap = data[0];
    return dynamicToDouble(itemAmtMap.values.first);
  }

  /// @Total money, @Disc money, @Surcharge money
  Future<List<double>> getAmount(int salesNo, int splitNo) async {
    final String query =
        "Select	Sum(Quantity * ItemAmount * Case When FunctionID=26 Then 1 Else 0 End), Sum((Discount + PromotionSaving) * Case When FunctionID=25 Or FunctionID=26 Then 1 Else 0 End), Sum(Discount * Case When FunctionID=55 Then 1 Else 0 End) From HeldItems Where SalesNo=$salesNo And SplitNo=$splitNo And FOCType not in ('FOC Item','BuyXfreeY') And (TransStatus=' ' Or TransStatus='D' Or TransStatus='M')";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return mapListToDouble2D(data)[0];
  }

  /// SP_HDS_DiscBill

  Future<String> getChineseTitle(String fnTitle, int fnID, int sFnID) async {
    final query =
        "Select IFNULL(Title_Chinese, '$fnTitle') From SubFunction Where FunctionID=$fnID And SubFunctionID=$sFnID";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return data[0].get(0).toString();
  }

  /// (Select Max(ItemSeqNo) From HeldItems Where SalesNo=@SalesNo And ItemSeqNo not in (101,102))
  Future<int> getItemSeqNo(int salesNo) async {
    final query =
        "Select Max(ItemSeqNo) From HeldItems WHERE SalesNo=$salesNo And ItemSeqNo not in (101,102)";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return dynamicToInt(data[0].get(0));
  }

  /// (Select ItemSeqNo From HeldItems Where SalesNo=@SalesNo And SplitNo=@SplitNo And SalesRef=@SalesRef)
  Future<int> getSItemSeqNo({
    required int salesNo,
    required int splitNo,
    required int salesRef,
  }) async {
    final query =
        "Select ItemSeqNo From HeldItems WHERE SalesNo=$salesNo And SplitNo=$splitNo And SalesRef=$salesRef";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return dynamicToInt(data[0].get(0));
  }

  /// @memId = MembershipID, @LoyaltyCardNo = LoyaltyCardNo, @NCover = Covers
  Future<List<String>> getHeldTableData(int salesNo, int splitNo) async {
    final query =
        "Select MembershipID, LoyaltyCardNo, Covers From HeldTables Where SalesNo=$salesNo And SplitNo=$splitNo";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return mapListToString2D(data)[0];
  }

  /// Select @CtgryID = DefCategoryID, @PLU_BillDiscount = PLU_BillDiscount, @PShift = DefSellBand, @blnForceSalesCategory = forcesalescategory, @blnForceSalesCategorySellband = ForceSalesCategorySellband From PosDtls Where POSID=@POSID
  Future<List<String>> getPosDtlsDataBill(String posID) async {
    final query =
        "Select DefCategoryID, PLU_BillDiscount, DefSellBand, forcesalescategory, ForceSalesCategorySellband From PosDtls Where POSID='$posID'";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return mapListToString2D(data)[0];
  }

  /// Select @CtgryID = DefCategoryID, @PShift = DefSellBand, @blnForceSalesCategory = forcesalescategory, @blnForceSalesCategorySellband = ForceSalesCategorySellband From POSDtls Where POSID=@POSID
  Future<List<String>> getPosDtlsDataItem(String posID) async {
    final query =
        "Select DefCategoryID, DefSellBand, forcesalescategory, ForceSalesCategorySellband From POSDtls Where POSID='$posID'";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return mapListToString2D(data)[0];
  }

  /// Select	IFNULL(Sum(Quantity * ItemAmount * Case When FunctionID=26 Then 1 Else 0 End), 0), IFNULL(Sum((Discount + PromotionSaving) * Case When FunctionID=25 Or FunctionID=26 Then 1 Else 0 End), 0), IFNULL(Sum(Discount * Case When FunctionID=55 Then 1 Else 0 End), 0) From HeldItems a Inner Join PLU b On b.PLUNumber=a.PLUNo Where SalesNo=$salesNo And SplitNo=$splitNo And FOCType not in ('FOC Item','BuyXfreeY') And (TransStatus=' ' Or TransStatus='D') And b.AllowDiscount=1
  Future<List<String>> getBillAmount(int salesNo, int splitNo) async {
    final query =
        "Select	IFNULL(Sum(Quantity * ItemAmount * Case When FunctionID=26 Then 1 Else 0 End), 0), IFNULL(Sum((Discount + PromotionSaving) * Case When FunctionID=25 Or FunctionID=26 Then 1 Else 0 End), 0), IFNULL(Sum(Discount * Case When FunctionID=55 Then 1 Else 0 End), 0) From HeldItems a Inner Join PLU b On b.PLUNumber=a.PLUNo Where SalesNo=$salesNo And SplitNo=$splitNo And FOCType not in ('FOC Item','BuyXfreeY') And (TransStatus=' ' Or TransStatus='D') And b.AllowDiscount=1";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return mapListToString2D(data)[0];
  }

  /// INSERT INTO HDS_HappyHourShift
  Future<void> insertHDSHappyHourShift(
      {required String posID,
      required int salesNo,
      required int splitNo,
      required String hpyShift1,
      required String hpyShift2,
      required String hpyShift3}) async {
    final query =
        "INSERT INTO HDS_HappyHourShift SELECT $posID, $salesNo, $splitNo, HpyHr1, HpyHr2, HpyHr3, IFNULL(HappyHourStart1, '00:00:00'), IFNULL(HappyHourStart2, '00:00:00'), IFNULL(HappyHourStart3, '00:00:00'), IFNULL(HappyHourStop1, '00:00:00'), IFNULL(HappyHourStop2, '00:00:00'), IFNULL(HappyHourStop3, '00:00:00'), $hpyShift1,$hpyShift2, $hpyShift3  FROM PosDtls WHERE POSID='$posID'";

    final database = await dbHelper.database;
    await database.rawQuery(query);
  }

  ///HpyHr1, HpyHr2, HpyHr2, HappyStar1, HappyStar2, HappyStart3, HpyEnd1, HpyEnd2, HpyEnd3, HpyPShift1, HpyPShift2, HpyPshift3,
  Future<List<String>> getHDSHappyHourShift(
      {required String posID,
      required int salesNo,
      required int splitNo}) async {
    final query =
        "SELECT HpyHr1, HpyHr2, HpyHr3, HappyHourStart1, HappyHourStart2, HappyHourStart3,@HpyEnd1 = HappyHourStop1,HappyHourStop2,HappyHourStop3,HpyPShift1,HpyPShift2,HpyPShift3 FROM HDS_HappyHourShift WHERE POSID='$posID' AND SalesNo=$salesNo AND SplitNo=$splitNo";

    final database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    return mapListToString2D(data)[0];
  }

  /// DELETE FROM HDS_HappyHourShift WHERE POSID=@POSID AND SalesNo=@SalesNo AND SplitNo=@SplitNo
  Future<void> deleteHappyHourShift(
      {required String posID,
      required int salesNo,
      required int splitNo}) async {
    final query =
        "DELETE FROM HDS_HappyHourShift WHERE POSID='$posID' AND SalesNo=$salesNo AND SplitNo=$splitNo";

    final database = await dbHelper.database;
    await database.rawQuery(query);
  }
  // Get pShift End

  /// Add Disc Bill to HeldItems
  Future<void> addDiscBill(
      {required int salesNo,
      required String posID,
      required String sDate,
      required String sTime,
      required String fnTitle,
      required String fnTitleCh,
      required String tableNo,
      required int splitNo,
      required int operatorNo,
      required double qty,
      required double discAmnt,
      required double avgCost,
      required int rcpID,
      required int pShift,
      required int fnID,
      required int sFnID,
      required double discPercent,
      required int itemSeqNo,
      required int ctgryID,
      required int memId,
      required String loyaltyCardNo,
      required int nCover,
      required String discRemarks}) async {
    final query =
        "INSERT INTO HeldItems (PLUSalesRef,SalesNo,POSID,SDate,STime,ItemName,itemname_chinese,TableNo,SplitNo,OperatorNo,Quantity,ItemAmount,AvgCost,RecipeId,PriceShift,PLUNO,PromotionId,FunctionID,SubFunctionID,DiscountType,Discount,DiscountPercent,ItemSeqNo,CategoryID,RefundID,FOCItem,FOCType,MembershipID,LoyaltyCardNo,Covers,TransMode,TransStatus,SeatNo,serverno,cc_promo2) VALUES (0, $salesNo, $posID, $sDate, $sTime, $fnTitle, $fnTitleCh, $tableNo, $splitNo, $operatorNo, $qty, $discAmnt, $avgCost,$rcpID, $pShift, '000000000000000', 0, $fnID, $sFnID,$fnTitle, $discAmnt, $discPercent, $itemSeqNo, $ctgryID, 0, 0,' ',$memId, $loyaltyCardNo, $nCover, 'REG', ' ', 0, $operatorNo, $discRemarks)";

    final database = await dbHelper.database;
    await database.rawQuery(query);
  }

  /// Update HeldItems
  Future<void> updateHeldItemsDiscBill(
      {required String tableNo,
      required int salesNo,
      required int splitNo,
      required int itemSeqNo}) async {
    final query =
        "UPDATE HeldItems SET PLUSalesRef=SalesRef WHERE TableNo=$tableNo And SalesNo=$salesNo And SplitNo=$splitNo And ItemSeqNo=$itemSeqNo";

    final database = await dbHelper.database;
    await database.rawQuery(query);
  }

  /// Update HeldTables (int splitNo)
  Future<void> updateHeldTables(int salesNo, int splitNo) async {
    final query =
        "UPDATE HeldTables SET PrntStatus=' ' WHERE SalesNo=$salesNo And SplitNo=$splitNo And PrntStatus='P'";

    final database = await dbHelper.database;
    await database.rawQuery(query);
  }

  // Sp_HDS_DiscItem

  /// UPDATE HeldItems SET DiscountPercent=@DiscPercent, Discount=@DiscAmnt, DiscountType=@FnTitle, cc_promo2=@DiscRemarks WHERE SalesNo=@SalesNo AND Splitno=@Splitno AND ItemSeqNo=@SItemSeqNo
  Future<void> updateHeldItemsDiscItem({
    required double discPercent,
    required double discAmnt,
    required String fnTitle,
    required String discRemarks,
    required int salesNo,
    required int splitNo,
    required int sItemSeqNo,
  }) async {
    final query =
        "UPDATE HeldItems SET DiscountPercent=$discPercent, Discount=$discAmnt, DiscountType=$fnTitle, cc_promo2=$discRemarks WHERE SalesNo=$salesNo AND Splitno=$splitNo AND ItemSeqNo=$sItemSeqNo";

    final database = await dbHelper.database;
    await database.rawQuery(query);
  }

  /// Add Disc Item to HeldItems
  Future<void> addDiscItem(
      {required int PLUSalesRef,
      required int salesNo,
      required String posID,
      required String sDate,
      required String sTime,
      required String fnTitle,
      required String fnTitleCh,
      required String tableNo,
      required int splitNo,
      required int operatorNo,
      required double qty,
      required double discAmnt,
      required double avgCost,
      required int rcpID,
      required int pShift,
      required String PLUNo,
      required int fnID,
      required int sFnID,
      required double discPercent,
      required int itemSeqNo,
      required int ctgryID,
      required int memId,
      required String loyaltyCardNo,
      required String discRemarks}) async {
    final query =
        "INSERT INTO HeldItems (PLUSalesRef,SalesNo,POSID,SDate,STime,ItemName,itemname_chinese,TableNo,SplitNo,OperatorNo,Quantity,ItemAmount,AvgCost,RecipeId,PriceShift,PLUNO,PromotionId,FunctionID,SubFunctionID,Discount,DiscountPercent,DiscountType,ItemSeqNo,CategoryID,RefundID,FOCItem,FOCType,MembershipID,LoyaltyCardNo,TransMode,TransStatus,SeatNo,serverno,cc_promo2) VALUES ($PLUSalesRef, $salesNo, $posID, $sDate,  $sTime, $fnTitle, $fnTitleCh, $tableNo, $splitNo, $operatorNo, $qty,$discAmnt, $avgCost, $rcpID, $pShift,  $PLUNo, 0, $fnID, $sFnID, $discAmnt, $discPercent, $fnTitle, $itemSeqNo, $ctgryID, 0, 0,' ', $memId, $loyaltyCardNo, 'REG', ' ', 0, $operatorNo, $discRemarks)";

    final database = await dbHelper.database;
    await database.rawQuery(query);
  }

  /// Select sc_SellPriceShift From SalesCategory Where CategoryID=@CtgryID
  Future<int> getSellPriceShift(int ctgryID) async {
    final query =
        "Select sc_SellPriceShift From SalesCategory Where CategoryID=$ctgryID";

    final database = await dbHelper.database;
    List<Map<String, dynamic>> data = await database.rawQuery(query);
    return mapListToInt2D(data)[0][0];
  }
}
