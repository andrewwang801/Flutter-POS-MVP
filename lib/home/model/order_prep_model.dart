class OrderPrepModel {
  OrderPrepModel(
      {required this.prepNumber,
      required this.prepName,
      required this.prepQuantity,
      required this.prepAmount,
      required this.prepSalesRef});

  final String prepNumber;
  final String prepName;
  final double prepQuantity;
  final double prepAmount;
  final int prepSalesRef;
}
