import 'package:raptorpos/home/model/modifier.dart';
import 'package:raptorpos/home/model/order_item_model.dart';

abstract class IOrderRepository {
  Future<List<int>> getTaxFromSC(int catID);
  Future<int?> getTaxCode();
  Future<bool> checkExemptTax(String pluTax, String pluNo);
  Future<void> updateItemTax(
      String strTax, int salesNo, int splitNo, int salesRef);
  Future<int?> getItemSalesRef(
      int salesNo, int splitNo, String tableNo, int itemSeqNo, int status);

  Future<int> countPLU(String pluNo, int status);
  Future<int> countItem(String pluNo, int salesNo, int splitNo, int salesRef);
  Future<List<List<String>>> getPLUDetailsByNumber(String pluNo);
  Future<int> countSoldPLU(String pluNo);
  Future<void> updateSoldPLU(int pluSold, String pluNumber);
  Future<void> updatePLUSalesRef(List<String> data, int status);
  Future<int?> getMaxSalesRef(int salesNo, int splitNo, int salesRef);
  Future<void> insertKPStatus(
      int salesNo, int splitNo, int itemSeqNo, int selPluKp);
  Future<int> getItemSeqNo(int salesNo);

  Future<int> insertOrderItem(OrderItemModel orderItem);
  Future<List<OrderItemModel>> fetchOrderItems(
      int salesNo, int splitNo, String tableNo);

  Future<void> updateOrderStatus(List<String> data, int status);

  Future<List<double>> fetchAmountOrder(
      int salesNo, int splitNo, String tableNo, bool taxIncl);
  Future<List<List<String>>> getTaxRateData();

  /// Get order items from HeldItems table
  Future<OrderItemModel?> getOrderSelectData(int salesRef);
  Future<OrderItemModel?> getModSelectData(int salesRef);
  Future<List<OrderItemModel>> getPrepSelectData(int salesRef);
  Future<int> getPrepStatus(int salesNo, int splitNo, int salesRef);
  Future<OrderItemModel?> getLastOrderData(
      int salesNo, int splitNo, String tableNo);
  Future<ModifierModel?> getModDtls(String modifier);
  Future<OrderItemModel?> getItemParentData(
      int salesNo, int splitNo, int salesRef);
  Future<String?> getItemData(
      String pluNo, int salesNo, int splitNo, int salesRef);
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
      int salesRef);

  Future<void> updateHoldItem(int salesNo, int splitNo, String tableNo,
      double sTotal, double gTotal, double padiAmount);
}
