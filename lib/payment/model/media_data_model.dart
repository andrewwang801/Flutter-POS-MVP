import 'package:json_annotation/json_annotation.dart';

part 'media_data_model.g.dart';

@JsonSerializable()
class MediaData {
  MediaData(
      {required this.funcID,
      required this.title,
      required this.titleChinese,
      required this.subFuncID,
      required this.tenderValue,
      required this.minimum,
      required this.maximum,
      required this.propForCustID,
      required this.printSignature,
      required this.applyTax});

  final int funcID;
  final String title;
  final String titleChinese;
  final int subFuncID;
  final double tenderValue;
  final double minimum;
  final double maximum;
  final bool propForCustID;
  final bool printSignature;
  final bool applyTax;

  factory MediaData.fromJson(Map<String, dynamic> json) =>
      _$MediaDataFromJson(json);
  Map<String, dynamic> toJson() => _$MediaDataToJson(this);
}
