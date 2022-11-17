import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

import '../../common/GlobalConfig.dart';
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
    final String strDate = currentDateTime('ddd');
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
}
