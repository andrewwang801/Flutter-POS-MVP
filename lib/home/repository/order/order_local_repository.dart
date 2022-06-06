import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:provider/provider.dart';
import 'package:raptorpos/home/model/menu_item_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:raptorpos/common/helper/db_helper.dart';
import 'package:raptorpos/home/model/order_item_model.dart';
import 'package:raptorpos/home/repository/order/i_order_repository.dart';
import 'package:raptorpos/common/extension/string_extension.dart';

@Injectable(as: IOrderRepository)
class OrderLocalRepository implements IOrderRepository {
  final LocalDBHelper database;
  OrderLocalRepository({required this.database});

  @override
  bool checkExemptTax(String pluTax, String pluNo) {
    throw UnimplementedError();
  }

  @override
  Future<int> countPLU(String pluNo, int status) async {
    String query = '';
    if (status == 1) {
      query = 'SELECT COUNT(*) FROM PLU WHERE PLUNumber = \'$pluNo\'';
    } else if (status == 2) {
      query =
          'SELECT COUNT(*) FROM PLU WHERE PLUNumber = \'$pluNo\' AND plutaxexempt = 1';
    } else {
      query = 'SELECT COUNT(*) FROM modifier WHERE message = \'$pluNo\'';
    }

    final Database db = await database.database;
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      return maps[0].entries.first.value;
    }
    return 0;
  }

  @override
  Future<int> countSoldPLU(String pluNo) async {
    final Database db = await database.database;
    String query =
        'SELECT COUNT(*) FROM SoldPLU WHERE PLUNumber = \'$pluNo\' AND PLUSold = 0';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      return maps[0].entries.first.value as int;
    }
    return 0;
  }

  @override
  int getMaxSalesRef(int salesNo, int splitNo, int salesRef) {
    throw UnimplementedError();
  }

  @override
  Future<List<List<String>>> getPLUDetailsByNumber(String pluNo) async {
    // String query =
    // 'SELECT PLUName, Department, Sell ${POSDtls.DefPShift}, KP1, KP2, KP3, LnkTo, RecipeID, CostPrice, Preparation, PLUName_Chinese, RentalItem, comments, TrackPrepItem, DeptTrackPrepItem, TaxTag FROM PLU WHERE PLUNumber = \'$pluNo \'';

    String query =
        'SELECT PLUName, Department, Sell1, KP1, KP2, KP3, LnkTo, RecipeID, CostPrice, Preparation, PLUName_Chinese, RentalItem, comments, TrackPrepItem, DeptTrackPrepItem, TaxTag FROM PLU WHERE PLUNumber = \'$pluNo\'';

    final Database db = await database.database;
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) {
      return e.entries.map((e) {
        return e.value.toString();
      }).toList();
    }).toList();
  }

  @override
  int getTaxCode() {
    throw UnimplementedError();
  }

  @override
  Future<List<int>> getTaxFromSC(int catID) async {
    final Database db = await database.database;
    String query =
        'SELECT IFNULL(Tax0, 0), IFNULL(Tax1, 0), IFNULL(Tax2, 0), IFNULL(Tax3, 0), IFNULL(Tax4, 0), IFNULL(Tax5, 0), IFNULL(Tax6, 0), IFNULL(Tax7, 0), IFNULL(Tax8, 0), IFNULL(Tax9, 0) FROM SalesCategory WHERE CategoryID =$catID';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    final Map<String, dynamic> data = maps[0];
    return data.entries.map((e) {
      return e.value as int;
    }).toList();
  }

  @override
  void insertKPStatus(int salesNo, int splitNo, int itemSeqNo, int selPluKp) {}

  @override
  Future<int> insertOrderItem(OrderItemModel orderItem) async {
    final Database db = await database.database;
    int ret = await db.insert('HeldItems', orderItem.toJson());
    return ret;
  }

  @override
  void updateItemTax() {}

  @override
  void updateOrderStatus(List<String> data, int status) {}

  @override
  void updatePLUSalesRef(List<String> data, int status) {}

  @override
  void updateSoldPLU(int pluSold, String pluNumber) {}

  @override
  Future<int> getItemSeqNo(int salesNo) async {
    String query =
        'SELECT IFNULL(MAX(ItemSeqNo),0) FROM HeldItems WHERE SalesNo = $salesNo AND ItemSeqNo NOT IN (101, 102)';
    final Database db = await database.database;
    List<Map> maps = await db.rawQuery(query);
    return maps[0].entries.first.value;
  }

  @override
  Future<List<OrderItemModel>> fetchOrderItems() async {
    final Database db = await database.database;
    String query =
        "SELECT CASE WHEN FunctionID = 26 THEN Quantity ELSE 0 END as Quantity, ItemName, PLUNo, (Quantity * ItemAmount * CASE WHEN (FOCItem = 0 OR FOCItem = 'BuyXFreeY') THEN 1 ELSE 0 END), ItemAmount, SalesRef, PLUSalesRef, TransStatus, IFNULL(SetMenu, 0), IFNULL(LnkTo, ' '), FunctionID, TblHold, A.CategoryID, ItemSeqNo, FOCItem FROM HeldItems A LEFT JOIN SalesCategory B ON A.CategoryID = B.CategoryID AND ItemSeqNo NOT IN (101, 102) AND FunctionID IN (12, 24, 25, 26, 55, 101) AND (TransStatus = ' ' OR TransStatus = 'D') AND Preparation = 0 ORDER BY SalesRef, PLUSalesRef";
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) {
      return OrderItemModel.fromJson(e);
    }).toList();
  }

  // Move to Payment Repository
  @override
  Future<List<double>> fetchAmountOrder(
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

    final Database db = await database.database;
    String query = 'SELECT inclusive FROM TaxRates WHERE SalesTax = 1';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    bool itemTaxIncl = (maps[0].entries.first.value as int).toBool();

    query =
        "SELECT IFNULL(TAmnt, 0), IFNULL(Disc, 0), IFNULL(Surcharge, 0) FROM (SELECT SUM(Quantity * ItemAmount * CASE WHEN (FunctionID = 26 AND FOCItem = 0) THEN 1 ELSE 0 END) AS TAmnt, SUM((IFNULL(Discount, 0) + IFNULL(PromotionSaving, 0)) * CASE WHEN (FunctionID = 25 OR FunctionID = 26) AND FOCItem = 0 THEN 1 ELSE 0 END) AS Disc, SUM(IFNULL(Discount, 0) * CASE WHEN FunctionID = 55 THEN 1 ELSE 0 END) AS Surcharge FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D')) AS a";
    maps = await db.rawQuery(query);
    double tAmnt = 0.00, disc = 0.00, surCharge = 0.00;
    if (maps.length > 0) {
      final tempData = maps[0];
      tAmnt = (tempData.entries.elementAt(0).value as int).toDouble();
      disc = (tempData.entries.elementAt(1).value as int).toDouble();
      surCharge = (tempData.entries.elementAt(2).value as int).toDouble();
    }

    double sTotal = tAmnt;
    double gTotal = sTotal - disc + surCharge;
    double taxTotal = 0.00;

    if (!taxIncl) {
      List<double> taxList =
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
      List<double> taxList =
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
    List<double> taxData = <double>[
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
    String query =
        'SELECT TaxCode, Title, PrintTax, TaxRate FROM TaxRates WHERE TaxRate > 0 AND PrintTax = 1 ORDER BY appliestonett DESC, TaxCode';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
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
        "SELECT COUNT(SalesNo) FROM HeldItems WHERE SalesNo = $SalesNo AND SplitNo = $SplitNo";
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    int count = maps[0].entries.first.value;
    if (count > 0) {
      TableName = "HeldItems";
    } else {
      TableName = "SalesItemsTemp";
    }

    query =
        "SELECT IFNULL(SUM(ItemAmount), 0) FROM $TableName WHERE SalesNo = $SalesNo AND SplitNo = $SplitNo AND FunctionID = 25 AND ItemAmount <> 0 AND TransStatus = ' '";
    maps = await db.rawQuery(query);
    TBillDisc = (maps[0].entries.first.value as int).toDouble();

    query =
        "SELECT IFNULL(SUM(Quantity * ItemAmount * CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END), 0), IFNULL(SUM((IFNULL(PromotionSaving, 0) + IFNULL(Discount, 0)) * (CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END)), 0) FROM $TableName WHERE SalesNo = SalesNo  AND SplitNo = SplitNo AND (TransStatus = ' ' OR TransStatus = 'D')";
    maps = await db.rawQuery(query);
    var tempData = maps[0];
    Amount = (tempData.entries.elementAt(0).value as int).toDouble();
    Disc = (tempData.entries.elementAt(1).value as int).toDouble();

    STtl = Amount - Disc;
    GTotal = STtl - TBillDisc;

    bool exemptable, discInc, appliesToNett, salesTax, inclusive;
    String title;

    query =
        "SELECT TaxCode, Exemptable, DiscInclusive, TaxRate, Title, AppliesToNett, SalesTax, inclusive FROM TaxRates WHERE TaxRate > 0 AND MinTaxable < ${GTotal.toString()} ORDER BY AppliesToNett DESC, TaxCode";
    maps = await db.rawQuery(query);
    for (int i = 0; i < maps.length; i++) {
      tempData = maps[i];

      TaxCode = tempData.entries.elementAt(0).value;
      exemptable = (tempData.entries.elementAt(1).value as int).toBool();
      discInc = (tempData.entries.elementAt(2).value as int).toBool();
      TPercent = double.tryParse(tempData.entries.elementAt(3).value) ?? 0.00;
      title = tempData.entries.elementAt(4).value;
      appliesToNett = (tempData.entries.elementAt(5).value as int).toBool();
      salesTax = (tempData.entries.elementAt(6).value as int).toBool();
      inclusive = (tempData.entries.elementAt(7).value as int).toBool();

      strTax = "ApplyTax$TaxCode";
      TaxRate = TPercent / 100;
      STax = 0.00;
      ItemTotal = 0.00;
      ItemDisc = 0.00;
      BillDisc = 0.00;

      query =
          'SELECT IFNULL(SUM((Quantity * ItemAmount) * (CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END)), 0), IFNULL(SUM((IFNULL(PromotionSaving,0) + IFNULL(Discount,0)) * (CASE WHEN FunctionID = 26 THEN 1 ELSE 0 END)), 0) FROM $TableName WHERE SalesNo = $SalesNo AND SplitNo = $SplitNo  AND (TransStatus = \' \' OR TransStatus = \'D\') AND $strTax  = 1';
      maps = await db.rawQuery(query);
      tempData = maps[0];
      ItemTotal = (tempData.entries.elementAt(0).value as int).toDouble();
      ItemDisc = (tempData.entries.elementAt(1).value as int).toDouble();

      if (ItemTotal == 0) {
        STax = 0.00;
      } else {
        String SurchargeFeature;
        double Surcharge;
        query =
            "SELECT IFNULL(Feature,' ') FROM $TableName h INNER JOIN SubFunction s ON h.FunctionID = s.FunctionID AND h.SubFunctionID = s.SubFunctionID WHERE h.SalesNo = $SalesNo AND h.SplitNo = $SplitNo AND h.FunctionID = 55 AND h.TransStatus = ' '";
        maps = await db.rawQuery(query);
        if (maps.length == 0) {
          SurchargeFeature = " ";
        } else {
          tempData = maps[0];
          String text = tempData.entries.elementAt(0).value;
          SurchargeFeature = text.substring(0, 1);
        }

        if (SurchargeFeature == "2") {
          query =
              "SELECT IFNULL(Discount,0) FROM  TableName  WHERE SalesNo = $SalesNo AND SplitNo = $SplitNo AND FunctionID = 55 AND TransStatus = ' '";
          maps = await db.rawQuery(query);
          tempData = maps[0];

          Surcharge = tempData.entries.elementAt(0).value;
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

    List<double> taxData = <double>[
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

  Future<MenuItemModel?> getOrderSelectData(int salesRef) async {
    final Database db = await database.database;
    String query = '';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return MenuItemModel.fromJson(maps[0]);
  }

  Future<MenuItemModel?> getModSelectData(int salesRef) async {
    final Database db = await database.database;
    String query = '';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return MenuItemModel.fromJson(maps[0]);
  }

  Future<MenuItemModel?> getPrepSelectData(int salesRef) async {
    final Database db = await database.database;
    String query = '';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return MenuItemModel.fromJson(maps[0]);
  }

  Future<MenuItemModel?> getLastOrderData(int salesRef) async {
    final Database db = await database.database;
    String query = '';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return MenuItemModel.fromJson(maps[0]);
  }

  Future<void> doFOCItem() async {}
}

final Provider<IOrderRepository> orderLocalRepoProvider =
    Provider<IOrderRepository>(create: (ref) => GetIt.I<IOrderRepository>());
