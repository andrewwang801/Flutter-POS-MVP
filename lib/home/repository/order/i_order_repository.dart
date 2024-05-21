import 'package:raptorpos/home/model/order_item_model.dart';

abstract class IOrderRepository {
  Future<List<int>> getTaxFromSC(int catID);
  int getTaxCode();
  bool checkExemptTax(String pluTax, String pluNo);
  void updateItemTax();

  Future<int> countPLU(String pluNo, int status);
  Future<List<List<String>>> getPLUDetailsByNumber(String pluNo);
  Future<int> countSoldPLU(String pluNo);
  void updateSoldPLU(int pluSold, String pluNumber);
  void updatePLUSalesRef(List<String> data, int status);
  int getMaxSalesRef(int salesNo, int splitNo, int salesRef);
  void insertKPStatus(int salesNo, int splitNo, int itemSeqNo, int selPluKp);
  Future<int> getItemSeqNo(int salesNo);

  Future<int> insertOrderItem(OrderItemModel orderItem);
  Future<List<OrderItemModel>> fetchOrderItems();

  void updateOrderStatus(List<String> data, int status);

  Future<List<double>> fetchAmountOrder(
      int salesNo, int splitNo, int tableNo, bool taxIncl);
  Future<List<List<String>>> getTaxRateData();
}
