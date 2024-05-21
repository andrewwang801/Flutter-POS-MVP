import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:raptorpos/home/model/modifier.dart';
import 'package:sqflite/sqflite.dart';
import 'package:raptorpos/common/helper/db_helper.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/repository/order/i_order_repository.dart';
import 'package:raptorpos/common/extension/string_extension.dart';

import 'package:raptorpos/common/utils/type_util.dart';

@Injectable(as: IOrderRepository)
class OrderLocalRepository with TypeUtil implements IOrderRepository {
  final LocalDBHelper database;
  OrderLocalRepository({required this.database});

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

        if (SurchargeFeature == "2") {
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
    double balance = gTotal - paidAmount;

    String query =
        "UPDATE HeldTables SET STotal = $sTotal, GTotal = $gTotal, PaidAmount = $paidAmount, Balance = $balance, TransStatus = 'H' WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND TableNo = '$tableNo'";
    dbHandler.rawQuery(query);

    query =
        'UPDATE HeldItems SET TblHold = 1 WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
    dbHandler.rawQuery(query);
  }
}

final Provider<IOrderRepository> orderLocalRepoProvider =
    Provider<IOrderRepository>(create: (ref) => GetIt.I<IOrderRepository>());
