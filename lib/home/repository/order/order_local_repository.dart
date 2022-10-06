import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:raptorpos/common/GlobalConfig.dart';
import 'package:raptorpos/common/utils/datetime_util.dart';
import 'package:raptorpos/home/model/modifier.dart';
import 'package:raptorpos/home/model/order_mod_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:raptorpos/common/helper/db_helper.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/common/extension/string_extension.dart';

import 'package:raptorpos/common/utils/type_util.dart';

import '../../../payment/repository/i_payment_repository.dart';
import '../../model/order_prep_model.dart';
import '../../model/prep/prep_model.dart';
import 'i_order_repository.dart';

@Injectable(as: IOrderRepository)
class OrderLocalRepository
    with TypeUtil, DateTimeUtil
    implements IOrderRepository {
  final LocalDBHelper database;
  final IPaymentRepository paymentRepository;
  OrderLocalRepository(this.paymentRepository, {required this.database});

  @override
  Future<bool> checkExemptTax(String pluTax, String pluNo) async {
    final Database db = await database.database;
    final String query =
        "SELECT $pluTax FROM PLU WHERE PLUNumber = '$pluNo' AND plutaxexempt = 1";
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      final int val = cast<int>(maps[0].values.elementAt(0)) ?? 0;
      return val.toBool();
    }
    return false;
  }

  @override
  Future<int> countPLU(String pluNo, int status) async {
    String query = '';
    if (status == 1) {
      query = "SELECT COUNT(*) FROM PLU WHERE PLUNumber = '$pluNo'";
    } else if (status == 2) {
      query =
          "SELECT COUNT(*) FROM PLU WHERE PLUNumber = '$pluNo' AND plutaxexempt = 1";
    } else {
      query = "SELECT COUNT(*) FROM modifier WHERE message = '$pluNo'";
    }

    final Database db = await database.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      return cast<int>(maps[0].entries.first.value) ?? 0;
    }
    return 0;
  }

  @override
  Future<int> countSoldPLU(String pluNo) async {
    final Database db = await database.database;
    final String query =
        "SELECT COUNT(*) FROM SoldPLU WHERE PLUNumber = '$pluNo' AND PLUSold = 0";
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      return maps[0].entries.first.value as int;
    }
    return 0;
  }

  @override
  Future<int> getPrepStatus(int salesNo, int splitNo, int salesRef) async {
    final Database db = await database.database;
    final String query =
        'SELECT IFNULL(Preparation,0) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo  AND SalesRef = $salesRef';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      final int val = cast<int>(maps[0].entries.first.value) ?? 0;
      return val;
    }
    return 0;
  }

  @override
  Future<String?> getItemData(
      String pluNo, int salesNo, int splitNo, int salesRef) async {
    final Database db = await database.database;

    String query =
        "SELECT SeatNo FROM HeldItems WHERE PLUNo = '$pluNo' AND SalesNo = $salesNo AND SplitNo = $splitNo AND SalesRef = $salesRef";

    if (pluNo == '-1') {
      query =
          'SELECT PLUNo FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo  AND SalesRef = $salesRef';
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      return maps[0].values.first.toString();
    }
    return null;
  }

  @override
  Future<OrderItemModel?> getItemParentData(
      int salesNo, int splitNo, int salesRef) async {
    final Database db = await database.database;
    final String query =
        'SELECT PLUNo, CategoryID FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND SalesRef = $salesRef';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      return OrderItemModel.fromJson(maps[0]);
    }
    return null;
  }

  @override
  Future<int?> getItemSalesRef(int salesNo, int splitNo, String tableNo,
      int itemSeqNo, int status) async {
    final Database db = await database.database;
    String query =
        "SELECT SalesRef FROM HeldItems WHERE TableNo = '$tableNo' AND SalesNo = $salesNo AND SplitNo = $splitNo AND ItemSeqNo = $itemSeqNo";
    if (status == 1) {
      query =
          'SELECT CASE WHEN SetMenuRef = 0 THEN PLUSalesRef ELSE SetMenuRef END FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND SalesRef = $itemSeqNo';
    }
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      final int val = cast<int>(maps[0].values.elementAt(0)) ?? 0;
      return val;
    }
    return null;
  }

  @override
  Future<int?> getMaxSalesRef(int salesNo, int splitNo, int salesRef) async {
    final Database db = await database.database;
    String query =
        'SELECT Max(SalesRef) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    if (salesRef > 0) {
      query =
          'SELECT Max(SalesRef) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND ItemName IN (SELECT ItemName FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND SalesRef = $salesRef)';
    }
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      final int val = cast<int>(maps[0].values.elementAt(0)) ?? 0;
      return val;
    }
    return null;
  }

  @override
  Future<List<List<String>>> getPLUDetailsByNumber(String pluNo) async {
    // String query =
    // 'SELECT PLUName, Department, Sell ${POSDtls.DefPShift}, KP1, KP2, KP3, LnkTo, RecipeID, CostPrice, Preparation, PLUName_Chinese, RentalItem, comments, TrackPrepItem, DeptTrackPrepItem, TaxTag FROM PLU WHERE PLUNumber = \'$pluNo \'';

    final String query =
        "SELECT PLUName, Department, Sell1, KP1, KP2, KP3, LnkTo, RecipeID, CostPrice, Preparation, PLUName_Chinese, RentalItem, comments, TrackPrepItem, DeptTrackPrepItem, TaxTag FROM PLU WHERE PLUNumber = '$pluNo'";

    final Database db = await database.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) {
      return e.entries.map((e) {
        return e.value.toString();
      }).toList();
    }).toList();
  }

  @override
  Future<int?> getTaxCode() async {
    final Database db = await database.database;
    const String query =
        'SELECT TaxCode FROM TaxRates WHERE TaxRate != 0 AND Exemptable = 1';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      final int val = cast<int>(maps[0].values.elementAt(0)) ?? 0;
      return val;
    }
    return null;
  }

  @override
  Future<List<int>> getTaxFromSC(int catID) async {
    final Database db = await database.database;
    final String query =
        'SELECT IFNULL(Tax0, 0), IFNULL(Tax1, 0), IFNULL(Tax2, 0), IFNULL(Tax3, 0), IFNULL(Tax4, 0), IFNULL(Tax5, 0), IFNULL(Tax6, 0), IFNULL(Tax7, 0), IFNULL(Tax8, 0), IFNULL(Tax9, 0) FROM SalesCategory WHERE CategoryID =$catID';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    final Map<String, dynamic> data = maps[0];
    return data.entries.map((e) {
      return e.value as int;
    }).toList();
  }

  @override
  Future<void> insertKPStatus(
      int salesNo, int splitNo, int itemSeqNo, int selPluKp) async {
    final Database db = await database.database;

    const String query =
        'INSERT INTO KPStatus(SalesNo, SplitNo, ItemSeqNo, KPNo, PrintToKp, BVoidPStatus, KPSeqNo, KPOrderNo)';
    final String values =
        ' VALUES ( $salesNo , $splitNo, $itemSeqNo, $selPluKp, 1, 1, 1, 1 )';
    await db.rawQuery('$query$values');
  }

  @override
  Future<int> insertOrderItem(OrderItemModel orderItem) async {
    final Database db = await database.database;
    final int ret = await db.insert('HeldItems', orderItem.toJson());
    return ret;
  }

  @override
  Future<void> updateItemTax(
      String strTax, int salesNo, int splitNo, int salesRef) async {
    final Database db = await database.database;
    final String query =
        'UPDATE HeldItems SET $strTax WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND SalesRef = $salesRef';
    await db.rawQuery(query);
  }

  @override
  Future<void> updateOrderStatus(List<String> data, int status) async {
    final Database db = await database.database;
    String query;
    switch (status) {
      case 1:
        query =
            'UPDATE KPStatus SET PrintToKp = 0 WHERE SalesNo = ${data[0]} AND SplitNo = ${data[1]} AND ItemSeqNo = ${data[2]}';
        break;
      case 2:
        query =
            'UPDATE HeldItems SET TblHold = 1 WHERE SalesNo = ${data[0]} AND SplitNo = ${data[1]} AND SalesRef = ${data[2]}';

        break;
      case 3:
      default:
        query =
            'UPDATE HeldItems SET TblHold = 1, PLUSalesRef = ${data[0]}, SetMenuRef = ${data[0]} WHERE SalesNo = ${data[1]} AND SplitNo = ${data[2]} AND SalesRef = ${data[3]}';

        break;
    }
    await db.rawQuery(query);
  }

  @override
  Future<void> updatePLUSalesRef(List<String> data, int status) async {
    final Database db = await database.database;
    String query =
        "UPDATE HeldItems SET PLUSalesRef = SalesRef WHERE TableNo = '${data[2]}' AND SalesNo = ${data[0]} AND SplitNo = ${data[1]} AND ItemSeqNo = ${data[3]}";
    if (status == 2) {
      query =
          'UPDATE HeldItems SET PLUSalesRef = ${data[0]}, SetMenu = 1, SetMenuRef = ${data[0]} WHERE SalesNo = ${data[1]} AND SplitNo = ${data[2]} AND ItemSeqNo = ${data[3]}';
    }
    await db.rawQuery(query);
  }

  @override
  Future<void> updateSoldPLU(int pluSold, String pluNumber) async {
    final Database db = await database.database;
    final String query =
        "UPDATE SoldPLU SET PLUSold = $pluSold WHERE PLUNumber = '$pluNumber'";
    await db.rawQuery(query);
  }

  @override
  Future<int> countItem(
      String pluNo, int salesNo, int splitNo, int salesRef) async {
    final Database db = await database.database;

    String query =
        "SELECT COUNT(*) FROM HeldItems WHERE PLUNo = '$pluNo' AND SalesNo = $salesNo AND SplitNo = $splitNo AND SalesRef = $salesRef";

    if (pluNo == '1') {
      query =
          'SELECT COUNT(*) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND SalesRef = $salesRef';
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      final int count = cast<int>(maps[0].values.elementAt(0)) ?? 0;
      return count;
    }
    return 0;
  }

  @override
  Future<int> getItemSeqNo(int salesNo) async {
    final String query =
        'SELECT IFNULL(MAX(ItemSeqNo),0) FROM HeldItems WHERE SalesNo = $salesNo AND ItemSeqNo NOT IN (101, 102)';
    final Database db = await database.database;
    final List<Map> maps = await db.rawQuery(query);
    return cast<int>(maps[0].entries.first.value) ?? 0;
  }

  @override
  Future<List<OrderItemModel>> fetchOrderItems(
      int salesNo, int splitNo, String tableNo) async {
    final Database db = await database.database;
    final String query =
        "SELECT CASE WHEN FunctionID = 26 THEN Quantity ELSE 0 END as Quantity, ItemName, PLUNo, (Quantity * ItemAmount * CASE WHEN (FOCItem = 0 OR FOCItem = 'BuyXFreeY') THEN 1 ELSE 0 END), ItemAmount, SalesRef, PLUSalesRef, TransStatus, IFNULL(SetMenu, 0), IFNULL(LnkTo, ' '), FunctionID, TblHold, A.CategoryID, ItemSeqNo, FOCItem, Preparation FROM HeldItems A LEFT JOIN SalesCategory B ON A.CategoryID = B.CategoryID WHERE SalesNo = $salesNo AND SplitNo = $splitNo  AND TableNo = '$tableNo'  AND ItemSeqNo NOT IN (101, 102) AND FunctionID IN (12, 24, 25, 26, 55, 101) AND (TransStatus = ' ' OR TransStatus = 'D') ORDER BY SalesRef, PLUSalesRef"; //AND Preparation = 0
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isEmpty) return [];
    return maps.map((e) {
      return OrderItemModel.fromJson(e);
    }).toList();
  }

  // Move to Payment Repository
  @override
  Future<List<double>> fetchAmountOrder(
      int salesNo, int splitNo, String tableNo, bool taxIncl) async {
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

    final Database db = await database.database;
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
  Future<List<List<String>>> getTaxRateData() async {
    final Database db = await database.database;
    const String query =
        'SELECT TaxCode, Title, PrintTax, TaxRate FROM TaxRates WHERE TaxRate > 0 AND PrintTax = 1 ORDER BY appliestonett DESC, TaxCode';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) {
      return e.entries.map((e) {
        return e.value.toString();
      }).toList();
    }).toList();
  }

  Future<List<double>> findTax(
      int SalesNo, int SplitNo, String TableNo, int digit) async {
    final Database db = await database.database;
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
    Amount = dynamicToDouble(tempData.entries.elementAt(0).value);
    Disc = dynamicToDouble(tempData.entries.elementAt(1).value);

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
      List<Map<String, dynamic>> maps2 = await db.rawQuery(query);
      tempData = maps2[0];
      ItemTotal = dynamicToDouble(tempData.entries.elementAt(0).value);
      ItemDisc = dynamicToDouble(tempData.entries.elementAt(1).value);

      if (ItemTotal == 0) {
        STax = 0.00;
      } else {
        String SurchargeFeature;
        double Surcharge;
        query =
            "SELECT IFNULL(Feature,' ') FROM $TableName h INNER JOIN SubFunction s ON h.FunctionID = s.FunctionID AND h.SubFunctionID = s.SubFunctionID WHERE h.SalesNo = $SalesNo AND h.SplitNo = $SplitNo AND h.FunctionID = 55 AND h.TransStatus = ' '";
        maps2 = await db.rawQuery(query);
        if (maps2.isEmpty) {
          SurchargeFeature = ' ';
        } else {
          tempData = maps2[0];
          final String text = tempData.entries.elementAt(0).value.toString();
          SurchargeFeature = text.substring(0, 1);
        }

        if (SurchargeFeature == "2") {
          query =
              "SELECT IFNULL(Discount,0) FROM  TableName  WHERE SalesNo = $SalesNo AND SplitNo = $SplitNo AND FunctionID = 55 AND TransStatus = ' '";
          maps2 = await db.rawQuery(query);
          tempData = maps2[0];

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
  Future<ModifierModel?> getModDtls(String modifier) async {
    final Database db = await database.database;
    final String query =
        "SELECT msgid, message, message_chinese FROM modifier WHERE message = '$modifier'";

    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      return ModifierModel.fromJson(maps[0]);
    }
    return null;
  }

  @override
  Future<OrderItemModel?> getOrderSelectData(int salesRef) async {
    final Database db = await database.database;
    final String query =
        "SELECT ItemName, Quantity, ItemAmount, (Quantity * ItemAmount * CASE WHEN (FOCItem = 0 OR FOCType = 'BuyXFreeY') THEN 1 ELSE 0 END) as totalAmount, FOCItem, TblHold, SetMenu FROM HeldItems WHERE SalesRef = $salesRef";
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.length > 0) {
      return OrderItemModel.fromJson(maps[0]);
    }
    return null;
  }

  @override
  Future<OrderItemModel?> getModSelectData(int salesRef) async {
    final Database db = await database.database;
    final String query =
        "SELECT ItemName FROM HeldItems WHERE PLUSalesRef = $salesRef AND TransStatus = 'M' AND Preparation = 1";
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.length > 0) {
      return OrderItemModel.fromJson(maps[0]);
    }
    return null;
  }

  @override
  Future<List<OrderItemModel>> getPrepSelectData(int salesRef) async {
    final Database db = await database.database;
    final String query =
        "SELECT PLUNo, Quantity, ItemName, TblHold FROM HeldItems WHERE PLUSalesRef = $salesRef AND Preparation = 1 AND (TransStatus = ' ' OR TransStatus = 'D')";
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.length > 0) {
      return maps.map((e) {
        return OrderItemModel.fromJson(e);
      }).toList();
    }
    return [];
  }

  @override
  Future<OrderItemModel?> getLastOrderData(
      int salesNo, int splitNo, String tableNo) async {
    final Database db = await database.database;
    final String query =
        "SELECT MAX(SalesRef) as SalesRef, MAX(ItemSeqNo) as ItemSeqNo FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo'";
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.length > 0) {
      return OrderItemModel.fromJson(maps[0]);
    }
    return null;
  }

  Future<void> doFOCItem(
      int salesNo,
      int splitNo,
      String tableNo,
      String posID,
      int operatorNo,
      int pShift,
      int itemSeqNo,
      int categoryID,
      String pluNo,
      int salesRef) async {
    final Database db = await database.database;

    const String itemName = 'FOC Item';
    final DateTime now = DateTime.now();
    final String strCurDate = DateFormat('yyyy-MM-dd').format(now);
    final String strCurTime = DateFormat('HH:mm:ss.0').format(now);

    String query =
        "SELECT Covers, Department, Quantity, ItemAmount, RecipeId, AvgCost, FOCItem FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo' AND SalesRef = $salesRef";
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isEmpty) {
      return;
    }
    final OrderItemModel orderItemModel = OrderItemModel.fromJson(maps[0]);
    final int cover = orderItemModel.Covers ?? 0;
    final int department = orderItemModel.Department ?? 0;
    final int quantity = orderItemModel.Quantity ?? 0;
    final double amount = orderItemModel.ItemAmount ?? 0;
    final int recipeId = orderItemModel.RecipeId ?? 0;
    final double avgCost = orderItemModel.AvgCost ?? 0.0;
    final bool focItem = (orderItemModel.FOCItem ?? 0).toBool();

    query =
        "SELECT FunctionID, SubFunctionID FROM SubFunction WHERE Title = '$itemName'";
    maps = await db.rawQuery(query);
    if (maps.isEmpty) {
      return;
    }
    final Map<String, dynamic> subFunc = maps[0];
    final int funcId = cast<int>(subFunc.values.elementAt(0)) ?? 0;
    final int subFuncId = cast<int>(subFunc.values.elementAt(1)) ?? 0;

    if (focItem || amount == 0) {
      throw Exception(['FOC Item Failed']);
    } else {
      query =
          "INSERT INTO HeldItems (PLUSalesRef, SalesNo, POSID, SDate, STime, ItemName, ItemName_Chinese, TableNo, Covers, Department, SplitNo, OperatorNo, Quantity, ItemAmount, PaidAmount, ChangeAmount, AvgCost, RecipeId, PriceShift, PLUNo, PromotionId, FunctionID, SubFunctionID, Discount, DiscountPercent, DiscountType, ItemSeqNo, CategoryID, Preparation, ApplyTax0, ApplyTax1, ApplyTax2, ApplyTax3, ApplyTax4, ApplyTax5, ApplyTax6, ApplyTax7, ApplyTax8, ApplyTax9, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, LnkTo, SetMenu, SetMenuRef, RefundID, FOCItem, FOCType, MembershipID, LoyaltyCardNo, TransMode, TransStatus, TblHold, comments, RentalItem, SalesAreaID, Trackprep, SeatNo, TaxTag, KDSPrint, ServerNo, cc_promo2) VALUES ($salesRef, $salesNo, '$posID', '$strCurDate', '$strCurTime', '$itemName', '$itemName', '$tableNo', $cover, $department, $splitNo, $operatorNo, $quantity, $amount, 0.00, 0.00, $avgCost, $recipeId, $pShift, '$pluNo', 0, $funcId, $subFuncId, 0.00, 0, ' ', $itemSeqNo, $categoryID, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 'R', 0, 0, 0, 1, '$itemName', 0, ' ', 'REG', ' ', 0, 0, 0, ' ', 0, 0, 'V', 0, $operatorNo, ' ')";
      await db.rawQuery(query);

      final double discFoc = quantity * amount;
      query =
          "UPDATE HeldItems SET DiscountType = '$itemName', DiscountPercent = 0, Discount = $discFoc, FOCItem = 1, FOCType = '$itemName', ApplyTax0 = 0, ApplyTax1 = 0, ApplyTax2 = 0, ApplyTax3 = 0, ApplyTax4 = 0, ApplyTax5 = 0, ApplyTax6 = 0, ApplyTax7 = 0, ApplyTax8 = 0, ApplyTax9 = 0 WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo' AND SalesRef = $salesRef AND ItemSeqNo = $itemSeqNo AND PLUNo = '$pluNo'";
      await db.rawQuery(query);
    }
  }

  @override
  Future<void> updateHoldItem(int salesNo, int splitNo, String tableNo,
      double sTotal, double gTotal, double paidAmount) async {
    final Database dbHandler = await database.database;
    final double balance = gTotal - paidAmount;

    String query =
        "UPDATE HeldTables SET STotal = $sTotal, GTotal = $gTotal, PaidAmount = $paidAmount, Balance = $balance, TransStatus = 'H' WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo'";
    dbHandler.rawQuery(query);

    query =
        'UPDATE HeldItems SET TblHold = 1 WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    dbHandler.rawQuery(query);
  }

  @override
  Future<List<List<String>>> getIndexOrder(String tableNo) async {
    final String query =
        "SELECT SalesNo, SplitNo, TableNo, Covers, RcptNo FROM HeldTables WHERE TableNo = '$tableNo'";

    final Database db = await database.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return mapListToString2D(maps);
  }

  @override
  Future<void> updateCovers(
      int salesNo, int splitNo, String tableNo, int cover) async {
    final Database db = await database.database;

    String query =
        "UPDATE HeldTables SET Covers = $cover WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo'";
    await db.rawQuery(query);
    query =
        "UPDATE HeldItems SET Covers = $cover WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo'";
    await db.rawQuery(query);
  }

  @override
  Future<void> updateOpenHoldTrans(
      int salesNo, int splitNo, String tableNo) async {
    final Database db = await database.database;
    final String query =
        "UPDATE HeldTables SET TransStatus = ' ' WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo'";
    await db.rawQuery(query);
  }

  @override
  Future<void> voidOrder(int salesNo, int splitNo, String tableNo, int salesRef,
      String remarks, int operatorNo) async {
    final Database dbHandler = await database.database;

    final String dateIn = currentDateTime('yyyy-MM-dd');
    final String timeIn = currentDateTime('HH:mm:ss');
    final String sDate = currentDateTime('yyyy-MM-dd');
    final String sTime = currentDateTime('HH:mm:ss');

    final String dateTime = '$dateIn $timeIn';

    String query =
        "SELECT IFNULL(SUM(VoidCount), 0) FROM OpHistory WHERE (DateIn || ' ' || TimeIn) = '$dateTime' AND OperatorNo = $operatorNo";
    List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    Map<String, dynamic> tempData = data[0];
    int vCount = dynamicToInt(tempData.get(0));

    if (salesRef == 0) {
      query =
          'SELECT Max(SalesRef) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (SetMenuRef = 0 OR PLUSalesRef = $salesRef)';
      data = await dbHandler.rawQuery(query);
      tempData = data[0];
      salesRef = dynamicToInt(tempData.get(0));
    }

    query =
        "SELECT COUNT(*) FROM HeldItems WHERE SalesRef = $salesRef AND SalesNo = $salesNo AND TransStatus = ' ' AND TblHold = 1";
    data = await dbHandler.rawQuery(query);
    tempData = data[0];
    final int postVoidCount = dynamicToInt(tempData.get(0));
    String addquery = "";

    if (postVoidCount > 0) {
      query =
          "UPDATE HeldItems SET Instruction = '$remarks' WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (SalesRef = $salesRef OR PLUSalesRef = $salesRef OR SetMenuRef = $salesRef)";
      await dbHandler.rawQuery(query);

      addquery = ', PostSendVoid = 1';
    }

    vCount++;
    query =
        "UPDATE OpHistory SET VoidCount = $vCount WHERE LstLogin = 1 AND POSID = '${POSDtls.deviceNo}' AND OperatorNo = $operatorNo";
    await dbHandler.rawQuery(query);

    query =
        "UPDATE HeldItems SET DiscountType = '', DiscountPercent = 0, Discount = 0.00 WHERE SalesRef IN (SELECT PLUSalesRef FROM HeldItems WHERE SalesRef = $salesRef AND TransStatus = ' ' AND FunctionID = 24)";
    await dbHandler.rawQuery(query);

    query =
        "UPDATE HeldItems SET PromotionID = 0, PromotionType = '', PromotionSaving = 0.00 WHERE SalesRef IN (SELECT PLUSalesRef FROM HeldItems WHERE SalesRef = $salesRef AND TransStatus = ' ' AND FunctionID = 12)";
    await dbHandler.rawQuery(query);

    query =
        "UPDATE HeldItems SET TransStatus = 'V' $addquery  WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (SalesRef = $salesRef OR PLUSalesRef = $salesRef OR SetMenuRef = $salesRef)";
    await dbHandler.rawQuery(query);

    query =
        "INSERT INTO HeldItems (POSID, Covers, TableNo, SalesNo, SplitNo, PLUSalesRef, PLUNo, Department, Quantity, ItemName, ItemName_Chinese, ItemAmount, PaidAmount, ChangeAmount, Gratuity, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, Adjustment, DiscountType, DiscountPercent, Discount, PromotionId, PromotionType, PromotionSaving, TransMode, RefundID, MembershipID, LoyaltyCardNo, CustomerID, CardScheme, CreditCardNo, AvgCost, RecipeId, PriceShift, CategoryId, TransferredTable, TransferredOp, KitchenPrint1, KitchenPrint2, KitchenPrint3, RedemptionItem, PointsRedeemed, ShiftID, PrintFreePrep, PrintPrepWithPrice, Preparation, FOCItem, FOCType, ApplyTax0, ApplyTax1, ApplyTax2, ApplyTax3, ApplyTax4, ApplyTax5, ApplyTax6, ApplyTax7, ApplyTax8, ApplyTax9, LnkTo, BuyXfreeYapplied, RndingAdjustments, PostSendVoid, TblHold, DepositID, SeatNo, OperatorNo, ItemSeqNo, SDate, STime, TransStatus, FunctionID, SubFunctionID, RentalItem, RentToDate, RentToTime, MinsRented, ServerNo, comments, Switchid, TrackPrep, Instruction, SalesAreaID, SetMenu, SetMenuRef, TaxTag, KDSPrint) SELECT HeldItems.POSID, HeldItems.Covers, HeldItems.TableNo, HeldItems.SalesNo, HeldItems.SplitNo, HeldItems.SalesRef, HeldItems.PLUNo, HeldItems.Department, HeldItems.Quantity, HeldItems.ItemName, HeldItems.ItemName_Chinese, HeldItems.ItemAmount, HeldItems.PaidAmount, HeldItems.ChangeAmount, HeldItems.Gratuity, HeldItems.Tax0, HeldItems.Tax1, HeldItems.Tax2, HeldItems.Tax3, HeldItems.Tax4, HeldItems.Tax5, HeldItems.Tax6, HeldItems.Tax7, HeldItems.Tax8, HeldItems.Tax9, HeldItems.Adjustment, HeldItems.DiscountType, HeldItems.DiscountPercent, HeldItems.Discount, HeldItems.PromotionId, HeldItems.PromotionType, HeldItems.PromotionSaving, HeldItems.TransMode, HeldItems.RefundID, HeldItems.MembershipID, HeldItems.LoyaltyCardNo, HeldItems.CustomerID, HeldItems.CardScheme, HeldItems.CreditCardNo, HeldItems.AvgCost, HeldItems.RecipeId, HeldItems.PriceShift, HeldItems.CategoryId, HeldItems.TransferredTable, HeldItems.TransferredOp, HeldItems.KitchenPrint1, HeldItems.KitchenPrint2, HeldItems.KitchenPrint3, HeldItems.RedemptionItem, HeldItems.PointsRedeemed, HeldItems.ShiftID, HeldItems.PrintFreePrep, HeldItems.PrintPrepWithPrice, HeldItems.Preparation, HeldItems.FOCItem, HeldItems.FOCType, HeldItems.ApplyTax0, HeldItems.ApplyTax1, HeldItems.ApplyTax2, HeldItems.ApplyTax3, HeldItems.ApplyTax4, HeldItems.ApplyTax5, HeldItems.ApplyTax6, HeldItems.ApplyTax7, HeldItems.ApplyTax8, HeldItems.ApplyTax9, HeldItems.LnkTo, HeldItems.BuyXfreeYapplied, HeldItems.RndingAdjustments, HeldItems.PostSendVoid, HeldItems.TblHold, HeldItems.DepositID, HeldItems.SeatNo, $operatorNo, HeldItems.ItemSeqNo, '$sDate', '$sTime', 'N', HeldItems.FunctionID, HeldItems.SubFunctionID, HeldItems.RentalItem, HeldItems.RentToDate, HeldItems.RentToTime, HeldItems.MinsRented, HeldItems.ServerNo, HeldItems.comments, HeldItems.Switchid, HeldItems.TrackPrep, HeldItems.Instruction, HeldItems.SalesAreaID, 0, 0, HeldItems.TaxTag, HeldItems.KDSPrint FROM HeldItems WHERE (HeldItems.SalesRef = $salesRef OR HeldItems.PLUSalesRef = $salesRef OR HeldItems.SetMenuRef = $salesRef) AND HeldItems.SalesRef NOT IN (SELECT PLUSalesRef FROM HeldItems WHERE TransStatus = 'N' AND SalesNo = $salesNo AND SplitNo = $splitNo)";
    await dbHandler.rawQuery(query);
  }

  @override
  Future<int> getPostVoidData(int salesRef, int salesNo) async {
    String query;
    if (salesRef != 0) {
      query =
          "SELECT COUNT(*) FROM HeldItems WHERE SalesRef = $salesRef AND SalesNo = $salesNo AND TransStatus = ' ' AND TblHold = 1";
    } else {
      query =
          "SELECT COUNT(*) FROM HeldItems WHERE SalesNo = $salesNo AND TransStatus = ' ' AND TblHold = 1";
    }

    Database dbHandler = await database.database;
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    int postVoid = 0;
    if (data.isNotEmpty) postVoid = dynamicToInt(data[0].get(0));
    return postVoid;
  }

  @override
  Future<List<List<String>>> getVoidRemarks() async {
    Database dbHandler = await database.database;
    const String query =
        'SELECT rem_id, remarks, remarks_chinese FROM VoidRemarks ORDER BY remarks';
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    return mapListToString2D(data);
  }

  // Update Order Item
  @override
  Future<void> updateItemQuantity(int salesNo, int splitNo, String tableNo,
      int quantity, int salesRef) async {
    final String query =
        "UPDATE HeldItems SET Quantity = $quantity WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo' AND SalesRef = $salesRef";
    final Database dbHandler = await database.database;
    await dbHandler.rawQuery(query);
  }

  @override
  Future<void> updateItemModifier(int salesNo, int splitNo, String tableNo,
      String modifier, int salesRef) async {
    final String query =
        "UPDATE HeldItems SET ItemName = '$modifier', ItemName_Chinese = '$modifier' WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo' AND SalesRef = $salesRef";
    final Database dbHandler = await database.database;
    await dbHandler.rawQuery(query);
  }

  Future<List<OrderPrepModel>> getOrderPrepData(
      int salesNo, int splitNo, int salesRef, String tableNo) async {
    List<OrderPrepModel> orderprepList = <OrderPrepModel>[];
    final String query =
        "SELECT PLUNo, ItemName, CASE WHEN FunctionID = 26 THEN Quantity ELSE 0 END, (Quantity * ItemAmount * CASE WHEN (FOCItem = 0 OR FOCType = 'BuyXFreeY') THEN 1 ELSE 0 END), SalesRef FROM HeldItems WHERE SalesNo = $salesNo  AND SplitNo = $splitNo AND TableNo = '%tableNo' AND ItemSeqNo NOT IN (101, 102) AND FunctionID IN (12,24,25,26,55,101) AND (TransStatus = ' ' OR TransStatus = 'D') AND PLUSalesRef = $salesRef AND Preparation = 1 ORDER BY PLUSalesRef, SalesRef";

    final Database dbHandler = await database.database;
    final List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    for (int i = 0; i < data.length; i++) {
      Map<String, dynamic> tempData = data[i];

      orderprepList.add(OrderPrepModel(
          prepNumber: tempData.get(0).toString(),
          prepName: tempData.get(1).toString(),
          prepQuantity: dynamicToDouble(tempData.get(2)),
          prepAmount: dynamicToDouble(tempData.get(3)),
          prepSalesRef: dynamicToInt(tempData.get(4))));
    }

    return orderprepList;
  }

  @override
  Future<List<OrderModData>> getOrderModData(
      int salesNo, int splitNo, int salesRef, String tableNo) async {
    List<OrderModData> ordermodList = <OrderModData>[];
    final String query =
        "SELECT ItemName, (Quantity * ItemAmount * CASE WHEN (FOCItem = 0 OR FOCType = 'BuyXFreeY') THEN 1 ELSE 0 END), SalesRef FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo' AND ItemSeqNo NOT IN (101, 102) AND FunctionID IN (12, 24, 25, 26, 55, 101) AND PLUSalesRef = $salesRef AND Preparation = 1 AND TransStatus = 'M' ORDER BY PLUSalesRef, SalesRef";

    final Database dbHandler = await database.database;
    List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    for (int i = 0; i < data.length; i++) {
      Map<String, dynamic> tempData = data[i];

      ordermodList.add(OrderModData(
          modName: tempData.get(0).toString(),
          modPrice: dynamicToDouble(tempData.get(1)),
          modSalesRef: dynamicToInt(tempData.get(1))));
    }

    return ordermodList;
  }

  // Void All Order
  @override
  Future<void> voidAllOrder(
      int salesNo,
      int splitNo,
      String tableNo,
      String posID,
      int operatorNo,
      int covers,
      String transMode,
      int memID,
      int pShift,
      int catID,
      String custID,
      String voidRemarks) async {
    final Database dbHandler = await database.database;

    String query =
        'SELECT AllVoid FROM Operator WHERE OperatorNo = $operatorNo';
    List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);
    Map<String, dynamic> tempData = data[0];

    final bool allVoidAccess = dynamicToBool(tempData.get(0));
    if (allVoidAccess) {
      final String dateIn = currentDateTime('yyyy-MM-dd');
      final String timeIn = currentDateTime('07:00:00.000');

      String datetime = '$dateIn $timeIn';

      query =
          "SELECT IFNULL(SUM(VoidCount), 0) FROM OpHistory WHERE (DateIn || ' ' || TimeIn) = '$datetime' AND OperatorNo = $operatorNo";
      data = await dbHandler.rawQuery(query);
      tempData = data[0];
      int voidCount = dynamicToInt(tempData.get(0));
      voidCount++;

      query =
          "UPDATE OpHistory SET VoidCount = $voidCount WHERE LstLogin = 1 AND POSID = '$posID' AND OperatorNo = $operatorNo";
      await dbHandler.rawQuery(query);

      String sDate = currentDateTime('yyyy-MM-dd');
      String sTime = currentDateTime('HH:mm:ss.0');

      query = 'SELECT SubFunctionID FROM SubFunction WHERE FunctionID = 32';
      data = await dbHandler.rawQuery(query);
      tempData = data[0];
      int subFuncID = dynamicToInt(tempData.get(0));

      query =
          "SELECT SalesRef, PLUSalesRef FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo'";
      data = await dbHandler.rawQuery(query);
      for (int i = 0; i < data.length; i++) {
        tempData = data[i];
        int salesRef = dynamicToInt(tempData.get(0));

        query =
            "SELECT COUNT(*) FROM HeldItems WHERE SalesRef = $salesRef AND SalesNo = $salesNo AND TransStatus = ' ' AND TblHold = 1";
        List<Map<String, dynamic>> data2 = await dbHandler.rawQuery(query);
        Map<String, dynamic> tempData2 = data2[0];
        int postVoidCount = dynamicToInt(tempData2.get(0));
        String addquery = '';

        if (postVoidCount > 0) {
          query =
              "UPDATE HeldItems SET Instruction = '$voidRemarks' WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (SalesRef = $salesRef OR PLUSalesRef = $salesRef OR SetMenuRef = $salesRef)";
          await dbHandler.rawQuery(query);

          addquery = ', PostSendVoid = 1';
        }

        query =
            "UPDATE HeldItems SET DiscountType = ' ', DiscountPercent = 0, Discount = 0.00 WHERE SalesRef IN (SELECT PLUSalesRef FROM HeldItems WHERE SalesRef = $salesRef AND TransStatus = ' ' AND FunctionID = 24)";
        await dbHandler.rawQuery(query);

        query =
            "UPDATE HeldItems SET PromotionID = 0, PromotionType = ' ', PromotionSaving = 0.00 WHERE SalesRef IN (SELECT PLUSalesRef FROM HeldItems WHERE SalesRef = $salesRef AND TransStatus = ' ' AND FunctionID = 12)";
        await dbHandler.rawQuery(query);

        query = "UPDATE HeldItems SET TransStatus = 'V'" +
            addquery +
            " WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (SalesRef = $salesRef OR PLUSalesRef = $salesRef OR SetMenuRef = $salesRef)";
        await dbHandler.rawQuery(query);

        query =
            "INSERT INTO HeldItems (POSID, OperatorNo, Covers, TableNo, SalesNo, SplitNo, PLUSalesRef, PLUNo, Department, Quantity, ItemName, ItemName_Chinese, ItemAmount, PaidAmount, ChangeAmount, Gratuity, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, Adjustment, DiscountType, DiscountPercent, Discount, PromotionId, PromotionType, PromotionSaving, TransMode, RefundID, MembershipID, LoyaltyCardNo, CustomerID, CardScheme, CreditCardNo, AvgCost, RecipeId, PriceShift, CategoryId, TransferredTable, TransferredOp, KitchenPrint1, KitchenPrint2, KitchenPrint3, RedemptionItem, PointsRedeemed, ShiftID, PrintFreePrep, PrintPrepWithPrice, Preparation, FOCItem, FOCType, ApplyTax0, ApplyTax1, ApplyTax2, ApplyTax3, ApplyTax4, ApplyTax5, ApplyTax6, ApplyTax7, ApplyTax8, ApplyTax9, LnkTo, BuyXfreeYapplied, RndingAdjustments, SetMenu, SetMenuRef, PostSendVoid, TblHold, DepositID, SeatNo, ItemSeqNo, SDate, STime, TransStatus, FunctionID, SubFunctionID, RentalItem, RentToDate, RentToTime, MinsRented, ServerNo, comments, Switchid, TrackPrep, Instruction, SalesAreaID, TaxTag, KDSPrint) SELECT HeldItems.POSID, $operatorNo AS Expr2, HeldItems.Covers, HeldItems.TableNo, HeldItems.SalesNo, HeldItems.SplitNo, HeldItems.SalesRef, HeldItems.PLUNo, HeldItems.Department, HeldItems.Quantity, HeldItems.ItemName, HeldItems.ItemName_Chinese, HeldItems.ItemAmount, HeldItems.PaidAmount, HeldItems.ChangeAmount, HeldItems.Gratuity, HeldItems.Tax0, HeldItems.Tax1, HeldItems.Tax2, HeldItems.Tax3, HeldItems.Tax4, HeldItems.Tax5, HeldItems.Tax6, HeldItems.Tax7, HeldItems.Tax8, HeldItems.Tax9, HeldItems.Adjustment, HeldItems.DiscountType, HeldItems.DiscountPercent, HeldItems.Discount, HeldItems.PromotionId, HeldItems.PromotionType, HeldItems.PromotionSaving, HeldItems.TransMode, HeldItems.RefundID, HeldItems.MembershipID, HeldItems.LoyaltyCardNo, HeldItems.CustomerID, HeldItems.CardScheme, HeldItems.CreditCardNo, HeldItems.AvgCost, HeldItems.RecipeId, HeldItems.PriceShift, HeldItems.CategoryId, HeldItems.TransferredTable, HeldItems.TransferredOp, HeldItems.KitchenPrint1, HeldItems.KitchenPrint2, HeldItems.KitchenPrint3, HeldItems.RedemptionItem, HeldItems.PointsRedeemed, HeldItems.ShiftID, HeldItems.PrintFreePrep, HeldItems.PrintPrepWithPrice, HeldItems.Preparation, HeldItems.FOCItem, HeldItems.FOCType, HeldItems.ApplyTax0, HeldItems.ApplyTax1, HeldItems.ApplyTax2, HeldItems.ApplyTax3, HeldItems.ApplyTax4, HeldItems.ApplyTax5, HeldItems.ApplyTax6, HeldItems.ApplyTax7, HeldItems.ApplyTax8, HeldItems.ApplyTax9, HeldItems.LnkTo, HeldItems.BuyXfreeYapplied, HeldItems.RndingAdjustments, 0, 0, HeldItems.PostSendVoid, HeldItems.TblHold, HeldItems.DepositID, HeldItems.SeatNo, HeldItems.ItemSeqNo, '$sDate' AS Expr4, '$sTime' AS Expr5, 'N' AS Expr6, HeldItems.FunctionID, $subFuncID, HeldItems.RentalItem, HeldItems.RentToDate, HeldItems.RentToTime, HeldItems.MinsRented, HeldItems.ServerNo, HeldItems.comments, HeldItems.Switchid, HeldItems.TrackPrep, HeldItems.Instruction, HeldItems.SalesAreaID, HeldItems.TaxTag, HeldItems.KDSPrint FROM HeldItems WHERE (HeldItems.SalesRef = $salesRef OR HeldItems.PLUSalesRef = $salesRef OR HeldItems.SetMenuRef = $salesRef) AND HeldItems.SalesRef NOT IN (SELECT PLUSalesRef FROM HeldItems WHERE TransStatus = 'N' AND SalesNo = $salesNo AND SplitNo = $splitNo )";
        await dbHandler.rawQuery(query);
      }

      query =
          "INSERT INTO HeldItems(POSID, OperatorNo, Covers, TableNo, SalesNo, SplitNo, PLUSalesRef, ItemSeqNo, PLUNo, Department, SDate, STime, Quantity, ItemName, ItemName_Chinese, ItemAmount, PaidAmount, ChangeAmount, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, DiscountType, DiscountPercent, Discount, PromotionId, PromotionType, PromotionSaving, TransMode, RefundID, TransStatus, FunctionID, SubFunctionID, MembershipID, LoyaltyCardNo, CustomerID, AvgCost, RecipeId, PriceShift, CategoryId, Preparation, FOCItem, FOCType, ApplyTax0, ApplyTax1, ApplyTax2, ApplyTax3, ApplyTax4, ApplyTax5, ApplyTax6, ApplyTax7, ApplyTax8, ApplyTax9, LnkTo, Setmenu, SetMenuRef, TblHold, RentalItem, SeatNo, SalesAreaID, ServerNo, comments, TaxTag, KDSPrint)";
      String values = " VALUES ( ";
      values +=
          "'$posID', $operatorNo, $covers, '$tableNo', $salesNo, $splitNo, 0, 102, '000000000000000', 0, '$sDate', '$sTime', 1, 'ALL VOID', 'ALL VOID', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '', 0, 0.00, 0, '', 0.00, '$transMode', 0, ' ', 32, 0, $memID, '', '', 0.00, '', $pShift, $catID, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 1, 0, 0, '', $operatorNo, 0, '', 0 )";

      query += values;
      await dbHandler.rawQuery(query);

      query =
          "UPDATE HeldTables SET STotal = 0.00, GTotal = 0.00, PaidAmount = 0.00, Balance = 0.00, Close_Date = '$sDate', Close_Time = '$sTime', TransStatus = 'V' WHERE SalesNo = $salesNo AND SPlitNo = $splitNo";
      await dbHandler.rawQuery(query);

      await paymentRepository.moveSales(salesNo, splitNo);
      await paymentRepository.moveSales2(salesNo, splitNo);
      await paymentRepository.moveSales3(salesNo, splitNo);

      if (tableNo != '') {
        query =
            "SELECT COUNT(TableNo) FROM HeldTables WHERE TableNo = '$tableNo'";
        data = await dbHandler.rawQuery(query);
        tempData = data[0];
        int countTables = dynamicToInt(tempData.get(0));
        if (countTables < 1) {
          query =
              "UPDATE TblLayout SET TBLStatus = 'A' WHERE TBLNo = '$tableNo'";
          dbHandler.rawQuery(query);
        } else {
          query =
              "UPDATE TblLayout SET TBLStatus = 'O' WHERE TBLNo IN (SELECT TableNo FROM HeldTables WHERE TableNo = '$tableNo')";
          dbHandler.rawQuery(query);
        }
      }
    } else {
      throw Exception(
          'Not Enough Permission \n Operator does not have rights to All Void');
    }
  }

  @override
  Future<void> updateTableStatus(String tableNo, String status) async {
    final String query =
        "UPDATE TblLayout SET TBLStatus = '$status' WHERE TBLNo IN (SELECT TableNo FROM HeldTables WHERE TableNo = '$tableNo')";

    final Database dbHandler = await database.database;
    await dbHandler.rawQuery(query);
  }
}

final Provider<IOrderRepository> orderLocalRepoProvider =
    Provider<IOrderRepository>(create: (ref) => GetIt.I<IOrderRepository>());
