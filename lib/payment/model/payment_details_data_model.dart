import 'package:json_annotation/json_annotation.dart';

part 'payment_details_data_model.g.dart';

@JsonSerializable()
class PaymentDetailsData {
  PaymentDetailsData(
      {required this.name, required this.amount, required this.salesRef});

  final String name;
  final double amount;
  final int salesRef;

  factory PaymentDetailsData.fromJson(Map<String, dynamic> json) =>
      _$PaymentDetailsDataFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentDetailsDataToJson(this);
}
