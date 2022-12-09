import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../../common/GlobalConfig.dart';
import '../../common/extension/string_extension.dart';
import '../../common/helper/db_helper.dart';
import '../../common/utils/datetime_util.dart';
import '../../common/utils/type_util.dart';
import '../../home/repository/order/i_order_repository.dart';
import '../model/promotion_model.dart';

@Injectable()
class PromotionLocalRepository with TypeUtil, DateTimeUtil {
  PromotionLocalRepository(this.dbHelper, this.orderRepository);

  final IOrderRepository orderRepository;
  final LocalDBHelper dbHelper;

  Future<bool> checkOpPromoAccess(int operatorNo) async {
    final String query =
        'SELECT op_promotion FROM Operator WHERE OperatorNo = $operatorNo';

    final Database database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);
    Map<String, dynamic> tempData = data[0];

    final bool op_promo = dynamicToBool(tempData.get(0));

    return op_promo;
  }

  Future<void> voidPromotion(int salesNo, int splitNo, int operatorNo) async {
    final Database dbHandler = await dbHelper.database;
    String query =
        'SELECT VoidPromotion FROM Operator WHERE OperatorNo = $operatorNo';
    List<Map<String, dynamic>> data = await dbHandler.rawQuery(query);

    if (data.isEmpty) {
      throw Exception('Void promotion is not availaboe for this operator');
    }

    final bool voidPromo = dynamicToBool(data[0].get(0));

    if (voidPromo) {
      query =
          "SELECT PromotionID FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PromotionType <> '' AND (TransStatus = ' ' OR TransStatus = 'D') GROUP BY PromotionID";
      data = await dbHandler.rawQuery(query);
      if (data.isNotEmpty) {
        for (int i = 0; i < data.length; i++) {
          final int promoId = dynamicToInt(data[i].get(0));

          query =
              'SELECT DiscountItems, BuyXfreeY, PrmnSellBand, X, Yfor, GroupDisc FROM Promotion WHERE PromotionID = $promoId';
          List<Map<String, dynamic>> data2 = await dbHandler.rawQuery(query);

          final bool discItem = dynamicToBool(data2[0].get(0));
          final bool prmnBuyXFreeY = dynamicToBool(data2[0].get(1));
          final bool prmnSellBand = dynamicToBool(data2[0].get(2));
          final int x = dynamicToInt(data2[0].get(3));
          final int yFor = dynamicToInt(data2[0].get(4));
          final bool groupDisc = dynamicToBool(data[0][5]);

          if (prmnSellBand) {
            query =
                "UPDATE HeldItems SET PromotionType = '', PromotionID = 0, PriceShift = 1, OperatorPromo = 0, PromotionSaving = 0.00 WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo IN (SELECT PLUNumber FROM PrmnSellBand WHERE PromotionID = $promoId) AND FOCItem = 0";
            await dbHandler.rawQuery(query);

            query =
                'SELECT Sell ${POSDtls.DefPShift}, ItemName FROM PLU INNER JOIN HeldItems ON PLU.PLUNumber = HeldItems.PLUNo INNER JOIN PrmnSellBand ON HeldItems.PLUNo = PrmnSellBand.PLUNumber WHERE HeldItems.SalesNo = $salesNo AND HeldItems.SplitNo = $splitNo AND PrmnSellBand.PromotionID = $promoId AND HeldItems.FunctionID != 33 AND HeldItems.FOCItem = 0';
            data2 = await dbHandler.rawQuery(query);

            for (int j = 0; j < data2.length; j++) {
              final double newAmt = dynamicToDouble(data2[j].get(0));
              final String iName = data2[j].get(1).toString();

              query =
                  'UPDATE HeldItems SET ItemAmount = $newAmt WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND ItemName = "$iName"';
              await dbHandler.rawQuery(query);
            }
          } else if (x != 0 && yFor != 0) {
            query =
                "UPDATE HeldItems SET PromotionType = '', PromotionID = 0, PromotionSaving = 0.00, OperatorPromo = 0 WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo IN (SELECT PLUNumber FROM PrmnBuyXpayY WHERE PromotionID = $promoId) AND FOCItem = 0";
            await dbHandler.rawQuery(query);
          } else if (discItem || groupDisc) {
            query =
                "UPDATE HeldItems SET PromotionID = 0, CC_Promo1 = '', PromotionType = '', CC_Promo2 = '', OperatorPromo = 0, PromotionSaving = 0.00 WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND FOCItem = 0";
            await dbHandler.rawQuery(query);
          } else if (prmnBuyXFreeY) {
            query =
                'SELECT DISTINCT PLUSalesRef, SalesRef FROM BuyXFreeY_Temp WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
            data2 = await dbHandler.rawQuery(query);
            for (int j = 0; j < data2.length; j++) {
              final int sRefParent = dynamicToInt(data2[j].get(0));
              final int sRefFree = dynamicToInt(data2[j].get(1));

              await orderRepository.voidOrder(salesNo, splitNo,
                  GlobalConfig.tableNo, sRefFree, '', operatorNo);

              query =
                  "UPDATE HeldItems SET promotionID = 0, PromotionType = '', BuyXfreeYapplied = 0, Promotionsaving = 0, operatorpromo = 0 WHERE SalesRef = $sRefParent AND TransStatus=' '";
              await dbHandler.rawQuery(query);

              query =
                  'DELETE FROM BuyXFreeY_Temp WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND SalesRef = $sRefFree';
              await dbHandler.rawQuery(query);
            }
          }
        }

        final String sDate = currentDateTime('yyyy-MM-dd');
        final String sTime = currentDateTime('HH:mm:ss');

        query =
            "INSERT INTO VoidPromo (SalesNo, SplitNo, POSID, OperatorNo, SDate, STime) VALUES($salesNo, $splitNo, '${POSDtls.deviceNo}',$operatorNo, '$sDate', '$sTime')";
        await dbHandler.rawQuery(query);
      } else {
        throw Exception('Cannot find any promotion.');
      }
    } else {
      throw Exception('Not Enough Permission.');
    }
  }

  // Get Promotion Data
  Future<List<PromotionModel>> getPromotionData() async {
    final Database databse = await dbHelper.database;
    final String strDate = currentDateTime('EEEE').substring(0, 3);
    final String query =
        'SELECT PromotionName, PromotionID FROM Promotion WHERE PActive = 1 AND Prmn$strDate = 1 ORDER BY SortNo, PromotionName, PrmnPriority';
    final List<Map<String, dynamic>> data = await databse.rawQuery(query);

    final List<PromotionModel> promotionList = <PromotionModel>[];
    for (final Map<String, dynamic> element in data) {
      promotionList.add(PromotionModel(
          element.get(0).toString(), dynamicToInt(element.get(1))));
    }

    return promotionList;
  }

  // Get Promotion Details
  Future<List<String>> getPromotionDetails(int promoID) async {
    final String strDate = currentDateTime('ddd');
    final String query =
        'SELECT PromotionName, Discount, DiscountItems, DateStart, DateEnd, TimeStart1, TimeEnd1, TimeStart2, TimeEnd2, BuyXfreeY, PrmnSellBand, SellAt, X, Yfor, GroupDisc FROM Promotion WHERE PromotionID = $promoID  AND PActive = 1 AND Prmn$strDate = 1';

    final Database database = await dbHelper.database;
    final List<Map<String, dynamic>> data = await database.rawQuery(query);

    final List<String> temp = <String>[];
    for (Map<String, dynamic> tempData in data) {
      temp.add(tempData[0].toString());
      temp.add(tempData[1].toString());
      temp.add(tempData[2].toString());

      temp.add(tempData[3].toString().substring(0, 10));
      temp.add(tempData[4].toString().substring(0, 10));
      temp.add(tempData[5].toString().substring(11));
      temp.add(tempData[6].toString().substring(11));
      temp.add(tempData[7].toString().substring(11));
      temp.add(tempData[8].toString().substring(11));

      temp.add(tempData[9].toString());
      temp.add(tempData[10].toString());
      temp.add(tempData[11].toString());
      temp.add(tempData[12].toString());
      temp.add(tempData[13].toString());
      temp.add(tempData[14].toString());
    }
    return temp;
  }

  // Apply Promotion
  Future<void> applyPromotion(
      int promoId, int salesNo, int splitNo, int operatorNo) async {
    final bool op_promo = await checkOpPromoAccess(operatorNo);

    if (op_promo) {
      final List<String> promoArray = await getPromotionDetails(promoId);

      final String promoName = promoArray[0];
      final double disc = promoArray[1].toDouble();
      final bool discItem = promoArray[2].toBool();
      final String DateStart = promoArray[3].substring(0, 10);
      final String DateEnd = promoArray[4].substring(0, 10);
      final String TimeStart1 = promoArray[5].substring(11);
      final String TimeEnd1 = promoArray[6].substring(11);
      final String TimeStart2 = promoArray[7].substring(11);
      final String TimeEnd2 = promoArray[8].substring(11);

      final bool PrmnBuyXFreeY = promoArray[9].toBool();
      final bool PrmnSellBand = promoArray[10].toBool();
      final int SellAt = promoArray[11].toInt();
      final int X = promoArray[12].toInt();
      final int YFor = promoArray[13].toInt();
      final bool GroupDisc = promoArray[14].toBool();

      final Database database = await dbHelper.database;

      String query = '';
      if (PrmnSellBand) {
        query =
            "SELECT COUNT(PLUNo) FROM HeldItems INNER JOIN PrmnSellBand ON HeldItems.PromotionID = PrmnSellBand.PromotionID AND HeldItems.PLUNo = PrmnSellBand.PLUNumber WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND FOCItem = 0";
        List<Map<String, dynamic>> data = await database.rawQuery(query);

        if (data.isNotEmpty) {
          // Function.ErrMsg = "Apply Promotion: " + promoName + " Failed!";
          // Function.ErrMsg2 = "Already applied promotion Sell Band!";

          throw Exception([
            'Apply Promotion: $promoName Failed!',
            'Already applied promotion Sell Band!'
          ]);
        } else {
          query =
              "SELECT COUNT(PLUNo) FROM HeldItems INNER JOIN PrmnSellBand ON HeldItems.PromotionID = PrmnSellBand.PromotionID AND HeldItems.PLUNo = PrmnSellBand.PLUNumber WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND FOCItem = 0";
          data = await database.rawQuery(query);
          final int countall = dynamicToInt(data[0].get(0));

          if (countall > 0) {
            query =
                "UPDATE HeldItems SET PromotionType = '$promoName', PromotionID = $promoId, PriceShift = 2, OperatorPromo = $operatorNo, PromotionSaving = 0 WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo IN (SELECT PLUNumber FROM PrmnSellBand WHERE PromotionID = $promoId) AND FOCItem = 0 AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL)";
            await database.rawQuery(query);

            query =
                'SELECT Sell $SellAt, ItemName FROM PLU INNER JOIN HeldItems ON PLU.PLUNumber = HeldItems.PLUNo INNER JOIN PrmnSellBand ON HeldItems.PLUNo = PrmnSellBand.PLUNumber WHERE HeldItems.SalesNo = $salesNo AND HeldItems.SplitNo = $splitNo AND PrmnSellBand.PromotionID = $promoId AND HeldItems.FOCItem = 0 AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL)';
            data = await database.rawQuery(query);

            for (int i = 0; i < data.length; i++) {
              final double newAmt = dynamicToDouble(data[i].get(0));
              final String itemName = data[i].get(1).toString();

              query =
                  'UPDATE HeldItems SET ItemAmount = $newAmt WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND ItemName = \"$itemName\"';
              await database.rawQuery(query);
            }
          } else {
            // Function.ErrMsg = "Apply Promotion: " + promoName + " Failed!";
            // Function.ErrMsg2 = "No items within time/date limit, promotion cannot be applied!: " + promoName;

            throw Exception([
              'Apply Promotion: $promoName Failed!',
              'No items within time/date limit, promotion cannot be applied!: $promoName'
            ]);
          }
        }
      } else if (X != 0 && YFor != 0) {
        query =
            "SELECT COUNT(PLUNo) FROM HeldItems INNER JOIN PrmnSellBand ON HeldItems.PromotionID = PrmnSellBand.PromotionID AND HeldItems.PLUNo = PrmnSellBand.PLUNumber WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND FOCItem = 0";
        var data = await database.rawQuery(query);

        if (data.length > 0) {
          // Function.ErrMsg = "Apply Promotion: " + promoName + " Failed!";
          // Function.ErrMsg2 = "Already applied promotion Sell Band!";

          throw Exception([
            'Apply Promotion: $promoName Failed!',
            'Already applied promotion Sell Band!'
          ]);
        } else {
          query =
              "SELECT COUNT(*) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (SDate >= '$DateStart' AND SDate <= '$DateEnd') AND ((STime >= '$TimeStart1' AND STime <= '$TimeEnd1') OR (STime >= '$TimeStart2' AND STime <= '$TimeEnd2')) AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND FOCItem = 0";
          data = await database.rawQuery(query);
          final int countall = dynamicToInt(data[0].get(0));

          if (countall > 0) {
            query =
                "UPDATE HeldItems SET PromotionType = '$promoName', PromotionID = $promoId, OperatorPromo = $operatorNo WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo IN (SELECT PLUNumber FROM PrmnBuyXpayY WHERE PromotionID = $promoId AND FOCItem = 0";
            await database.rawQuery(query);

            query =
                "SELECT DISTINCT(PLUNo) FROM HeldItems INNER JOIN PrmnBuyXpayY ON (HeldItems.PLUNo = PrmnBuyXpayY.PluNumber) WHERE (HeldItems.SalesNo = $salesNo AND (HeldItems.SplitNo = $splitNo AND (HeldItems.TransStatus = ' ' OR HeldItems.TransStatus = 'D') AND (HeldItems.FunctionID = 26) AND (HeldItems.SDate >= '$DateStart' AND HeldItems.SDate <= '$DateEnd') and ((HeldItems.STime >= '$TimeStart1' AND HeldItems.STime <= '$TimeEnd1') OR (HeldItems.STime >= '$TimeStart2' AND HeldItems.STime <= '$TimeEnd2')) AND (HeldItems.RedemptionItem = 0 OR HeldItems.RedemptionItem IS NULL) AND (HeldItems.BuyXfreeYapplied = 0 OR HeldItems.BuyXfreeYapplied IS NULL) AND HeldItems.FOCItem = 0 AND (PrmnBuyXpayY.PromotionID = $promoId)";
            data = await database.rawQuery(query);

            if (data.isNotEmpty) {
              final String PLUNo = data[0].get(0).toString();

              query =
                  "SELECT SalesRef, Quantity FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (SDate >= '$DateStart' AND SDate <= '$DateEnd') AND ((STime >= '$TimeStart1' AND STime <= '$TimeEnd1') OR (STime >= '$TimeStart2' AND STime <= '$TimeEnd2')) AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND FOCItem = 0 AND PLUNo = '$PLUNo' AND PromotionID = $promoId ORDER BY SalesRef DESC";
              data = await database.rawQuery(query);

              final int SRef = dynamicToInt(data[0].get(0));
              int SumQty = 0;
              for (int i = 0; i < data.length; i++) {
                final int qty = dynamicToInt(data[i].get(1));
                SumQty += qty;
              }

              if (SumQty < X) {
                query =
                    "UPDATE HeldItems SET PromotionType = '$promoName', PromotionID = $promoId, PromotionSaving = (CAST($SumQty / $X AS INT) * ($YFor) * ItemAmount), OperatorPromo = $operatorNo WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo IN (SELECT PLUNumber FROM PrmnBuyXpayY WHERE PromotionID = $promoId) AND FOCItem = 0 AND SalesRef = $SRef";
                await database.rawQuery(query);
              } else {
                query =
                    "UPDATE HeldItems SET PromotionType = '$promoName', PromotionID = $promoId, PromotionSaving = (CAST($SumQty / $X AS INT) * ($YFor) * ItemAmount), OperatorPromo = $operatorNo WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo IN (SELECT PLUNumber FROM PrmnBuyXpayY WHERE PromotionID = $promoId) AND FOCItem = 0 AND SalesRef = $SRef AND ($SumQty > $X)";
                await database.rawQuery(query);
              }

              query =
                  "UPDATE HeldItems SET PromotionSaving = 0, PromotionID = $promoId WHERE PLUNo = '$PLUNo' AND SalesRef <> $SRef AND SalesNo = $salesNo AND SplitNo = $splitNo";
              await database.rawQuery(query);
            }
          } else {
            // Function.ErrMsg = "Apply Promotion: " + promoName + " Failed!";
            // Function.ErrMsg2 = "No items within time/date limit, promotion cannot be applied!: " + promoName;

            throw Exception([
              'Apply Promotion: $promoName Failed!',
              'No items within time/date limit, promotion cannot be applied!: $promoName'
            ]);
          }
        }
      } else if (discItem) {
        query =
            "SELECT PLUNo FROM HeldItems INNER JOIN PrmnSellBand ON HeldItems.PromotionID = PrmnSellBand.PromotionID AND HeldItems.PLUNo = PrmnSellBand.PLUNumber WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND FOCItem = 0";
        var data = await database.rawQuery(query);

        if (data.isNotEmpty) {
          // Function.ErrMsg = "Apply Promotion: " + promoName + " Failed!";
          // Function.ErrMsg2 = "Already applied promotion Sell Band!";

          throw Exception([
            'Apply Promotion: $promoName Failed!',
            'Already applied promotion Sell Band!'
          ]);
        } else {
          // ignore: prefer_interpolation_to_compose_strings
          query = "SELECT COUNT(*) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (SDate >= '" +
              DateStart +
              "' AND SDate <= '" +
              DateEnd +
              "') AND ((STime >= '" +
              TimeStart1 +
              "' AND STime <= '" +
              TimeEnd1 +
              "') OR (STime >= '" +
              TimeStart2 +
              "' AND STime <= '" +
              TimeEnd2 +
              "')) AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND FOCItem = 0";
          data = await database.rawQuery(query);
          int countall = dynamicToInt(data[0].get(0));

          if (countall > 0) {
            query =
                "SELECT COUNT(*) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND FOCItem = 0 AND PromotionID = $promoId AND PromotionType = '$promoName'";
            data = await database.rawQuery(query);
            countall = dynamicToInt(data[0].get(0));

            if (countall == 0) {
              query =
                  'SELECT DISTINCT PrmnPlus.PluNumber, PrmnPlus.PluQty FROM PrmnPlus INNER JOIN HeldItems ON PrmnPlus.PluNumber = HeldItems.PluNo WHERE PrmnPlus.PromotionID = $promoId AND HeldItems.FOCItem = 0 ORDER BY PluNumber';
              data = await database.rawQuery(query);
              if (data.length > 0) {
                final String PLUNoPrm = data[0].get(0).toString();
                final double QtyPrm = dynamicToDouble(data[0].get(1));

                // ignore: prefer_interpolation_to_compose_strings
                query = "SELECT Quantity, SalesRef FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (SDate >= '" +
                    DateStart +
                    "' AND SDate <= '" +
                    DateEnd +
                    "') AND ((STime >= '" +
                    TimeStart1 +
                    "' AND STime <= '" +
                    TimeEnd1 +
                    "') OR (STime >= '" +
                    TimeStart1 +
                    "' AND STime <= '" +
                    TimeEnd2 +
                    "')) AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND FOCItem = 0 AND PLUNo = '$PLUNoPrm' ORDER BY ItemSeqNo";
                data = await database.rawQuery(query);

                if (data.isNotEmpty) {
                  final double QtyItems = dynamicToDouble(data[0].get(0));
                  final int SRefItems = dynamicToInt(data[0].get(1));

                  if (QtyItems >= QtyPrm) {
                    // ignore: prefer_interpolation_to_compose_strings
                    query = "UPDATE HeldItems SET PromotionID = $promoId, CC_Promo1 = '', PromotionType = '" +
                        promoName +
                        "', CC_Promo2 = '', OperatorPromo = 0, PromotionSaving = ROUND((($QtyPrm * ItemAmount) - IFNULL(Discount,0)) * $disc * 0.01,2) WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (SDate >= '" +
                        DateStart +
                        "' AND SDate <='" +
                        DateEnd +
                        "') AND ((STime >= '" +
                        TimeStart1 +
                        "' AND STime <= '" +
                        TimeEnd1 +
                        "') OR (STime >= '" +
                        TimeStart2 +
                        "' AND STime <= '" +
                        TimeEnd2 +
                        "')) AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND FOCItem = 0 AND SalesRef = $SRefItems";
                    await database.rawQuery(query);
                  } else {
                    // ignore: prefer_interpolation_to_compose_strings
                    query = "UPDATE HeldItems SET PromotionID = $promoId, CC_Promo1 = '', PromotionType = '" +
                        promoName +
                        "', CC_Promo2 = '', OperatorPromo = 0, PromotionSaving = ROUND(((Quantity * ItemAmount) - IFNULL(Discount,0)) * $disc * 0.01,2) WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (SDate >= '" +
                        DateStart +
                        "' AND SDate <='" +
                        DateEnd +
                        "') AND ((STime >= '" +
                        TimeStart1 +
                        "' AND STime <= '" +
                        TimeEnd1 +
                        "') OR (STime >= '" +
                        TimeStart2 +
                        "' AND STime <= '" +
                        TimeEnd2 +
                        "')) AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND FOCItem = 0 AND SalesRef = $SRefItems";
                    await database.rawQuery(query);
                  }
                }
              }
            } else {
              // Function.ErrMsg = "Apply Promotion: " + promoName + " Failed!";
              // Function.ErrMsg2 = "The same promotion is already applied!";

              throw Exception([
                'Apply Promotion: $promoName Failed!',
                'The same promotion is already applied!'
              ]);
            }
          } else {
            // Function.ErrMsg = "Apply Promotion: " + promoName + " Failed!";
            // Function.ErrMsg2 = "No items within time/date limit, promotion cannot be applied!: " + promoName;

            throw Exception([
              'Apply Promotion: $promoName Failed!',
              'No items within time/date limit, promotion cannot be applied!: $promoName'
            ]);
          }
        }
      } else if (GroupDisc) {
        query =
            "SELECT COUNT(PLUNo) FROM HeldItems INNER JOIN PrmnSellBand ON HeldItems.PromotionID = PrmnSellBand.PromotionID AND HeldItems.PLUNo = PrmnSellBand.PLUNumber WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND FOCItem = 0";
        List<Map<String, dynamic>> data = await database.rawQuery(query);

        if (data.isNotEmpty) {
          // Function.ErrMsg = "Apply Promotion: " + promoName + " Failed!";
          // Function.ErrMsg2 = "Already applied promotion Sell Band!";

          throw Exception([
            'Apply Promotion: $promoName Failed!',
            'Already applied promotion Sell Band!'
          ]);
        } else {
          // ignore: prefer_interpolation_to_compose_strings
          query = "SELECT COUNT(*) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (SDate >= '" +
              DateStart +
              "' AND SDate <= '" +
              DateEnd +
              "') AND ((STime >= '" +
              TimeStart1 +
              "' AND STime <= '" +
              TimeEnd1 +
              "') OR (STime >= '" +
              TimeStart2 +
              "' AND STime <= '" +
              TimeEnd2 +
              "')) AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND FOCItem = 0";
          data = await database.rawQuery(query);
          int countall = dynamicToInt(data[0].get(0));

          if (countall > 0) {
            query =
                "SELECT COUNT(*) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND FOCItem = 0 AND PromotionID = $promoId AND PromotionType = '$promoName'";
            data = await database.rawQuery(query);
            countall = dynamicToInt(data[0].get(0));

            if (countall == 0) {
              query =
                  "SELECT Department, PrmnGroups.DiscPercent FROM HeldItems INNER JOIN Departments ON (HeldItems.Department = Departments.DepartmentNo) INNER JOIN PrmnGroups ON (Departments.GroupNo = PrmnGroups.GroupNo) WHERE HeldItems.SalesNo = $salesNo AND HeldItems.SplitNo = $splitNo AND (HeldItems.TransStatus = ' ' OR HeldItems.TransStatus = 'D') AND HeldItems.FunctionID = 26 AND PrmnGroups.PromotionID = $promoId AND PrmnGroups.DiscPercent > 0 GROUP BY Department";
              data = await database.rawQuery(query);
              for (int i = 0; i < data.length; i++) {
                final int deptGetPrm = dynamicToInt(data[i].get(0));
                final double discPercent = dynamicToDouble(data[i].get(1));

                // ignore: prefer_interpolation_to_compose_strings
                query = "UPDATE HeldItems SET PromotionID = $promoId, cc_promo1 = '', PromotionType = '" +
                    promoName +
                    "', PromotionSaving = ROUND(((Quantity * ItemAmount) - IFNULL(Discount,0)) * $discPercent * 0.01,2), cc_promo2 = '', OperatorPromo = $operatorNo WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (SDate >= '" +
                    DateStart +
                    "' AND SDate <= '" +
                    DateEnd +
                    "') AND ((STime >= '" +
                    TimeStart1 +
                    "' AND STime <= '" +
                    TimeEnd1 +
                    "') OR (STime >= '" +
                    TimeStart2 +
                    "' AND STime <= '" +
                    TimeEnd2 +
                    "')) AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND FOCItem = 0 AND FOCType = ' ' AND Department = $deptGetPrm";
                await database.rawQuery(query);
              }
            } else {
              // Function.ErrMsg = "Apply Promotion: " + promoName + " Failed!";
              // Function.ErrMsg2 = "The same promotion is already applied!";

              throw Exception([
                'Apply Promotion: ' + promoName + ' Failed!',
                'The same promotion is already applied!'
              ]);
            }
          } else {
            // Function.ErrMsg = "Apply Promotion: " + promoName + " Failed!";
            // Function.ErrMsg2 = "No items within time/date limit, promotion cannot be applied!: " + promoName;

            throw Exception([
              'Apply Promotion: $promoName Failed!',
              'No items within time/date limit, promotion cannot be applied!: $promoName'
            ]);
          }
        }
      } else if (PrmnBuyXFreeY) {
        query =
            "SELECT COUNT(PLUNo) FROM HeldItems INNER JOIN PrmnSellBand ON HeldItems.PromotionID = PrmnSellBand.PromotionID AND HeldItems.PLUNo = PrmnSellBand.PLUNumber WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND FOCItem = 0";
        List<Map<String, dynamic>> data = await database.rawQuery(query);

        if (data.isNotEmpty) {
          // Function.ErrMsg = "Apply Promotion: " + promoName + " Failed!";
          // Function.ErrMsg2 = "Already applied promotion Sell Band!";

          throw Exception([
            'Apply Promotion: ' + promoName + ' Failed!',
            'Already applied promotion Sell Band!'
          ]);
        } else {
          // ignore: prefer_interpolation_to_compose_strings
          query = "SELECT COUNT(*) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (SDate >= '" +
              DateStart +
              "' AND SDate <= '" +
              DateEnd +
              "') AND ((STime >= '" +
              TimeStart1 +
              "' AND STime <= '" +
              TimeEnd1 +
              "') OR (STime >= '" +
              TimeStart2 +
              "' AND STime <= '" +
              TimeEnd2 +
              "')) AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND FOCItem = 0";
          data = await database.rawQuery(query);
          final int countall = dynamicToInt(data[0].get(0));

          if (countall > 0) {
            query =
                'SELECT DISTINCT PLUNo FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo';
            data = await database.rawQuery(query);

            for (int i = 0; i < data.length; i++) {
              final String PLUNo = data[i][0].toString();

              // ignore: prefer_interpolation_to_compose_strings
              query = "SELECT DISTINCT PLU.Department, IFNULL(HeldItems.BuyXfreeYapplied,0), HeldItems.PromotionID, IFNULL(HeldItems.PromotionType,0), IFNULL(HeldItems.PromotionSaving,0), Helditems.Quantity, qty, HeldItems.SalesRef, HeldItems.CategoryID, IFNULL(HeldItems.BuyXfreeYapplied,0), PrmnBuyXfreeY.BuyQty, PrmnBuyXfreeY.FreeQty, freeitems.itemno, freeitems.itemname, PrmnBuyXfreeY.FreeItemPrice, HeldItems.SeatNo, freeitems.itemname_chinese FROM HeldItems, PrmnBuyXfreeY, FreeItems, PLU, (SELECT HeldItems.PLUNo, SUM(HeldItems.Quantity) AS qty FROM HeldItems, PrmnBuyXfreeY, FreeItems WHERE PrmnBuyXfreeY.FreeItemCode = freeitems.FreeItemCode AND HeldItems.PLUNo = PrmnBuyXfreeY.PLUNumber AND SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 And (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND SDate >= '" +
                  DateStart +
                  "' AND SDate <= '" +
                  DateEnd +
                  "' AND ((STime >= '" +
                  TimeStart1 +
                  "' AND STime <= '" +
                  TimeEnd1 +
                  "') OR (STime >= '" +
                  TimeStart2 +
                  "' AND STime <= '" +
                  TimeEnd2 +
                  "')) AND (PrmnBuyXfreeY.PromotionID = $promoId) GROUP BY HeldItems.PLUNo) AS X WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND (TransStatus = ' ' OR TransStatus = 'D') AND FunctionID = 26 AND (RedemptionItem = 0 OR RedemptionItem IS NULL) AND (BuyXfreeYapplied = 0 OR BuyXfreeYapplied IS NULL) AND SDate >= '" +
                  DateStart +
                  "' AND SDate <= '" +
                  DateEnd +
                  "' AND ((STime >= '" +
                  TimeStart1 +
                  "' AND STime <= '" +
                  TimeEnd1 +
                  "') OR (STime >= '" +
                  TimeStart2 +
                  "' AND STime <= '" +
                  TimeEnd2 +
                  "')) AND X.PLUNO = HeldItems.PLUNO AND PrmnBuyXfreeY.FreeItemCode = FreeItems.FreeItemCode AND (HeldItems.PLUNo = PrmnBuyXfreeY.PLUNumber) AND (PrmnBuyXfreeY.PromotionID = $promoId) AND (FOCType = ' ') AND HeldItems.PLUNo = '" +
                  PLUNo +
                  "' AND PLU.PLUNumber = FreeItems.ItemNo";
              final List<Map<String, dynamic>> data2 =
                  await database.rawQuery(query);

              for (int j = 0; j < data2.length; j++) {
                final String FreePLUNo = data2[j].get(12).toString();
                final String FreeItemName = data2[j].get(13).toString();
                final String FreeItemName_Chinese = data2[j].get(16).toString();
                final int FreeItemDept = dynamicToInt(data2[j].get(0));
                final double FreeQty = dynamicToDouble(data2[j].get(11));
                final double BuyQty1 = dynamicToDouble(data2[j].get(10));

                final int SRef = dynamicToInt(data2[j].get(7));
                final int Qty = dynamicToInt(data2[j].get(5));
                int tempSeqNo = 0;

                query =
                    "SELECT ItemSeqNo FROM BuyXFreeY_Temp WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo = '$PLUNo' AND freePLUNo = '$FreePLUNo' ORDER BY ItemSeqNo DESC LIMIT 1";
                List<Map<String, dynamic>> data3 =
                    await database.rawQuery(query);
                if (data3.isNotEmpty) {
                  tempSeqNo = dynamicToInt(data3[0].get(0));
                }

                for (int k = 0; k < data2.length; k++) {
                  query =
                      "SELECT COUNT(*) FROM BuyXFreeY_Temp WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo = '$PLUNo' AND FreePLUNo = '$FreePLUNo' AND PLUSalesRef = $SRef";
                  data3 = await database.rawQuery(query);
                  final int value = dynamicToInt(data3[0].get(0));
                  if (value <= 0) {
                    for (int l = 0; l < Qty; l++) {
                      tempSeqNo += 1;
                      query =
                          "INSERT INTO BuyXFreeY_Temp (itemSeqNo, SalesNo, SplitNo, PLUNo, freePLUNo, PLUSalesRef, qty) VALUES ($tempSeqNo, $salesNo, $splitNo, '$PLUNo', '$FreePLUNo', $SRef, 0)";
                      await database.rawQuery(query);
                    }
                  }
                }

                // ignore: prefer_interpolation_to_compose_strings
                query = "SELECT IFNULL(SUM(quantity),0) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo = '" +
                    FreePLUNo +
                    "' AND FOCItem = 1 AND FOCType = 'buyxfreey' AND (TransStatus = ' ' OR TransStatus = 'D') AND SalesRef IN (SELECT SalesRef FROM BuyXFreeY_Temp WHERE PLUNo = '" +
                    PLUNo +
                    "' AND SalesNo = $salesNo AND SplitNo = $splitNo)";
                data3 = await database.rawQuery(query);
                double FreeY = dynamicToDouble(data3[0].get(0));

                query =
                    "SELECT COUNT(*) FROM BuyXFreeY_Temp WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo = '$PLUNo' AND freePLUNo = '$FreePLUNo' AND (SalesRef > 0 OR SalesRef IS NULL)";
                data3 = await database.rawQuery(query);
                double BuyQty2 = dynamicToDouble(data3[0].get(0));
                double FreeItemQty =
                    FreeQty * (BuyQty2 / BuyQty1 * BuyQty1) / BuyQty1;
                int status;

                if (FreeItemQty < FreeY) {
                  FreeItemQty -= FreeY;
                  if (FreeItemQty == 0) {
                    break;
                  } else {
                    BuyQty2 = FreeItemQty * BuyQty1;
                    status = 1;
                  }
                } else {
                  // ignore: prefer_interpolation_to_compose_strings
                  query = "SELECT * FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo = '" +
                      FreePLUNo +
                      "' AND FOCItem = 1 AND FOCType = 'buyxfreey' AND TransStatus = ' ' AND SalesRef NOT IN(SELECT DISTINCT SalesRef FROM BuyXfreeY_Temp WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND freePLUNo = '" +
                      FreePLUNo +
                      "' AND SalesRef <> 0 AND SalesRef IS NOT NULL)";
                  data3 = await database.rawQuery(query);
                  status = 2;

                  for (int k = 0; k < data3.length; k++) {
                    await orderRepository.voidOrder(salesNo, splitNo,
                        GlobalConfig.tableNo, SRef, '', operatorNo);
                  }

                  query =
                      "SELECT IFNULL(SUM(quantity),0) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo = '$FreePLUNo' AND FOCItem = 1 AND FOCType = 'buyxfreey' AND (TransStatus = ' ' OR TransStatus = 'D') AND SalesRef IN (SELECT SalesRef FROM BuyXFreeY_Temp WHERE PLUNo = '$PLUNo' AND SalesNo = $salesNo AND SplitNo = $splitNo)";
                  data3 = await database.rawQuery(query);
                  FreeY = dynamicToDouble(data3[0].get(0));

                  if (FreeItemQty == 0 || FreeItemQty == FreeY) {
                    continue;
                  } else if (FreeItemQty > FreeY) {
                    FreeItemQty -= FreeY;
                    if (FreeItemQty == 0) {
                      break;
                    } else {
                      BuyQty2 = FreeItemQty * BuyQty1;
                      status = 1;
                    }
                  }
                }

                final double FreeItemPrice = dynamicToDouble(data2[j].get(14));
                final int BuyXCtgry = dynamicToInt(data2[j].get(8));
                final int TmpSeatNo = dynamicToInt(data2[j].get(15));

                int RcpId = 0;
                double AvgCost = 0;

                query =
                    "SELECT RecipeID,CostPrice,LnkTo FROM PLU WHERE PLU.PLUNumber = '$FreePLUNo'";
                data3 = await database.rawQuery(query);
                RcpId = dynamicToInt(data3[0].get(0));
                AvgCost = dynamicToDouble(data3[0].get(1));
                final String PLULnkTo = data3[0].get(2).toString();

                final String SDate = currentDateTime('yyyy-MM-dd');
                final String STime = currentDateTime('HH:mm:ss');
                int PLUSRef = 0;

                if (status > 1) {
                  query =
                      "SELECT SUM(quantity) FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND FOCItem = 1 AND FOCType = 'buyxfreey' AND TransStatus = ' ' AND PLUNo = '$PLUNo'";
                  data3 = await database.rawQuery(query);
                  final double tempQty = dynamicToDouble(data3[0].get(0));
                  FreeItemQty = FreeItemQty - tempQty;

                  if (FreeItemQty < 1) {
                    query =
                        "UPDATE HeldItems SET promotionID = $promoId, PromotionType = '$promoName', BuyXfreeYapplied = 1, Promotionsaving = 0, operatorpromo = $operatorNo WHERE SalesRef = $PLUSRef AND TransStatus=' '";
                    await database.rawQuery(query);
                  }
                }

                int ISeqNo = 0;
                int data = await orderRepository.getItemSeqNo(salesNo);
                if (data == 100) {
                  ISeqNo = 103;
                } else {
                  ISeqNo = data + 1;
                }
                // final OrderItemFunction orderFunc = new OrderItemFunction();
                // final int ISeqNo = orderFunc.GetListSeqNo(SalesNo);

                query =
                    "INSERT INTO HeldItems (PLUSalesRef, SalesNo, POSID, SDate, STime, ItemName, TableNo, OperatorNo, Quantity, ItemAmount, PaidAmount, ChangeAmount, Tax0, Tax1, Tax2, Tax3, Tax4, Tax5, Tax6, Tax7, Tax8, Tax9, AvgCost, RecipeId, PriceShift, PLUNo, FunctionID, SubFunctionID, TransMode, SplitNo, ItemSeqNo, MembershipID, LoyaltyCardNo, PromotionID, RefundID, FOCItem, FOCType, Covers, CategoryID, Preparation, ApplyTax0, ApplyTax1, ApplyTax2, ApplyTax3, ApplyTax4, ApplyTax5, ApplyTax6, ApplyTax7, ApplyTax8, ApplyTax9, TransStatus, LnkTo, SetMenu, SetMenuRef, TblHold, SeatNo, serverno, itemname_chinese, operatorpromo, Department, RentalItem, salesAreaID, comments, TrackPrep, TaxTag, KDSPrint) VALUES (0, $salesNo, '${POSDtls.deviceNo}', '$SDate', '$STime', '$FreeItemName', '${GlobalConfig.tableNo}', $operatorNo, $FreeItemQty, $FreeItemPrice, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $AvgCost, $RcpId, '${POSDtls.PShift}', '$FreePLUNo', 26, 0, 'REG', $splitNo, $ISeqNo, 0, '000000', $promoId, 0, 1, 'BuyXfreeY', ${GlobalConfig.cover}, $BuyXCtgry, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ' ', '$PLULnkTo', 0, 0, 0, $TmpSeatNo, $operatorNo, '$FreeItemName_Chinese', $operatorNo, $FreeItemDept, 0, '${POSDtls.strSalesAreaID}', 0, 0, 'V', 0)";
                await database.rawQuery(query);

                query =
                    'UPDATE HeldItems SET PLUSalesRef = SalesRef WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND ItemSeqNo = $ISeqNo';
                await database.rawQuery(query);

                query =
                    'SELECT SalesRef FROM HeldItems WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND ItemSeqNo = $ISeqNo';
                data3 = await database.rawQuery(query);
                PLUSRef = dynamicToInt(data3[0].get(0));

                query =
                    "SELECT * FROM BuyXFreeY_Temp WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND freePLUNo = '$FreePLUNo' AND PLUNo = '$PLUNo' AND SalesRef IS NULL";
                data3 = await database.rawQuery(query);

                final double QtyCount = (FreeItemQty * BuyQty1) / FreeQty;
                for (int k = 0; k < QtyCount; k++) {
                  final int iseqNo = dynamicToInt(data3[k].get(0));
                  query =
                      "UPDATE BuyXFreeY_Temp SET SalesRef = $PLUSRef, Qty = $FreeQty WHERE ItemSeqNo = $iseqNo AND freePLUNo = '$FreePLUNo' AND PLUNo = '$PLUNo' AND SalesNo = $salesNo AND SplitNo = $splitNo";
                  await database.rawQuery(query);

                  query =
                      "UPDATE HeldItems SET promotionID = $promoId, PromotionType = '$promoName', BuyXfreeYapplied = 1, Promotionsaving = 0, operatorpromo = $operatorNo WHERE SalesRef = $PLUSRef AND TransStatus=' '";
                  await database.rawQuery(query);
                }

                query =
                    "SELECT KP1, KP2, KP3 FROM PLU WHERE PLUNumber = '$FreePLUNo'";
                data3 = await database.rawQuery(query);
                final int KP1 = dynamicToInt(data3[0].get(0));
                final int KP2 = dynamicToInt(data3[0].get(1));
                final int KP3 = dynamicToInt(data3[0].get(2));

                if (KP1 != 0) {
                  query =
                      'INSERT INTO KPStatus (SalesNo, SplitNo, ItemSeqNo, KPNo, PrintToKp,BVoidPStatus) VALUES ($salesNo, $splitNo, $ISeqNo, $KP1, 1, 1)';
                  await database.rawQuery(query);
                }

                if (KP2 != 0) {
                  query =
                      'INSERT INTO KPStatus (SalesNo, SplitNo, ItemSeqNo, KPNo, PrintToKp,BVoidPStatus) VALUES ($salesNo, $splitNo, $ISeqNo, $KP2, 1, 1)';
                  await database.rawQuery(query);
                }

                if (KP3 != 0) {
                  query =
                      'INSERT INTO KPStatus (SalesNo, SplitNo, ItemSeqNo, KPNo, PrintToKp,BVoidPStatus) VALUES ($salesNo, $splitNo, $ISeqNo, $KP3, 1, 1)';
                  await database.rawQuery(query);
                }

                query =
                    "SELECT PLUSalesRef FROM BuyXFreeY_Temp WHERE SalesNo = $salesNo AND SplitNo = $splitNo AND PLUNo = '$PLUNo'";
                data3 = await database.rawQuery(query);
                final int SRefParent = dynamicToInt(data3[0].get(0));

                query =
                    "UPDATE HeldItems SET promotionID = $promoId, PromotionType = '$promoName', BuyXfreeYapplied = 1, Promotionsaving = 0, operatorpromo = $operatorNo WHERE SalesRef = $SRefParent AND TransStatus=' '";
                await database.rawQuery(query);
              }
            }
          } else {
            // Function.ErrMsg = "Apply Promotion: " + promoName + " Failed!";
            // Function.ErrMsg2 = "No items within time/date limit, promotion cannot be applied!: " + promoName;

            throw Exception([
              'Apply Promotion: $promoName Failed!',
              'No items within time/date limit, promotion cannot be applied!: $promoName'
            ]);
          }
        }
      }
    } else {
      // Function.ErrMsg = "Apply Promotion Failed!";
      // Function.ErrMsg2 = "Not Enough Permission.";

      throw Exception(['Apply Promotion Failed!', 'Not Enough Permission.']);
    }
  }
}
