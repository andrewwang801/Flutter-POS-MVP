import 'package:json_annotation/json_annotation.dart';

part 'foc_bill_data_model.g.dart';

@JsonSerializable()
class FocBillData {
  FocBillData({required this.title, required this.subFuncID});

  final String title;
  final int subFuncID;

  factory FocBillData.fromJson(Map<String, dynamic> json) =>
      _$FocBillDataFromJson(json);
  Map<String, dynamic> toJson() => _$FocBillDataToJson(this);
}
