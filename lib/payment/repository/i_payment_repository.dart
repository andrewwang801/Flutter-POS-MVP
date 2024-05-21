import 'package:raptorpos/payment/model/foc_bill_data_model.dart';
import 'package:raptorpos/payment/model/media_data_model.dart';
import 'package:raptorpos/payment/model/payment_details_data_model.dart';

abstract class IPaymentRepository {
  // Basic DB Operations
  Future<int> countData(String query);
  Future<List<Map<String, dynamic>>> getData(String query);

  Future<bool> checkPaymentPermission(int operatorNo, int paymentType);
  Future<bool> checkTenderPayment(int salesNo, int splitNo, String tableNo);

  /// TaxCode, Title, PrintTax, TaxRate
  Future<List<Map<String, dynamic>>> getTaxRateData();
  Future<List<double>> getAmountOrder(
      int salesNo, int splitNo, int tableNo, bool taxIncl);
  Future<List<double>> findTax(
      int salesNo, int splitNo, String tableNo, int digit);
  Future<List<double>> findExTax(
      int salesNo, int splitNo, String tableNo, int digit, bool PLUBillDisc);
  Future<void> paymentItem(
      String posID,
      int operatorNo,
      String tableNo,
      int salesNo,
      int splitNo,
      int paymentType,
      double paidAmount,
      String customerID);

  // move sales
  Future<void> moveSales(int salesNo, int splitNo);
  Future<void> moveSales2(int salesNo, int splitNo);
  Future<void> moveSales3(int salesNo, int splitNo);

  /// TableNo, SplitNo, Covers, RcptNo
  Future<List<Map<String, dynamic>>> getOrderStatusBySNo(int salesNo);

  /// SUM(PaidAmount), ChangeAmount, SUM(ItemAmount)
  Future<Map<String, dynamic>> getPopUpAmount(int salesNo);

  Future<String> getBillFOCName(int salesNo);
  Future<double> getPaidAmount(int salesNo, int splitNo, String tableNo);
  Future<double> getTotalRemoveAmount(
      int salesNo, int splitNo, String tableNo, int salesRef);
  Future<void> doRemovePayment(
      int salesNo, int splitNo, String tableNo, int salesRef);

  // Media type
  Future<List<MediaData>> getMediaType();
  Future<List<MediaData>> getMediaByType(int funcID, int operatorNo);

  Future<List<PaymentDetailsData>> getPaymentDetails(
      int salesNo, int splitNo, String tableNo);
  Future<List<FocBillData>> getFocBillData();
  Future<List<bool>> getFOCBillProperty(int subFuncID);
  Future<bool> checkFocOperatorAccess(int operatorNo, int subFuncID);
  Future<bool> checkFOCBillAccess(int salesNo, int splitNo);
  Future<void> doFOCBill(
      int salesNo,
      int splitNo,
      String tableNo,
      int focType,
      String posID,
      int operatorNo,
      int pShift,
      String custID,
      String transMode);
  Future<void> insertFOCComments(
      int salesNo, int operatorFOC, int splitNo, String comments);

  // Print
  Future<List<List<String>>> getPrintCategory(int sNo);
  Future<List<List<String>>> getPrintItem(int sNo, String ctgName);
  Future<List<List<String>>> getPrintTotal(int sNo);
  Future<List<List<String>>> getPrintBillDisc(int sNo);
  Future<List<List<String>>> getTotalItemQty(int sNO);
  Future<List<List<String>>> getPrintPayment(int sNo);
  Future<List<List<String>>> getPrintTax(int sNo);
  Future<List<List<String>>> getPrintPromo(int sNo);
  Future<List<List<String>>> getPrintRefund(int sNo);
}
