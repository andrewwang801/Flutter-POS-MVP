import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'discount_model.g.dart';

@JsonSerializable()
class DiscountModel extends Equatable {
  @JsonKey(name: 'Title')
  final String discTitle;

  @JsonKey(name: 'FunctionID')
  final int fnctnID;

  @JsonKey(name: 'SubFunctionID')
  final int subFnID;

  @JsonKey(name: 'Feature')
  final int fnFeature;

  @JsonKey(name: 'Parameter')
  final String fnParm;

  @JsonKey(name: 'disc_remarks')
  final int disc_remarks;

  @JsonKey(name: 'CoverBased')
  final int coverBased;

  @JsonKey(name: 'CoverBasedType')
  final String coverbasedtype;

  @JsonKey(name: 'RGBColour')
  final String? color;

  DiscountModel(
      this.discTitle,
      this.fnctnID,
      this.subFnID,
      this.fnFeature,
      this.fnParm,
      this.disc_remarks,
      this.coverBased,
      this.coverbasedtype,
      this.color);

  @override
  List<Object?> get props => [];

  factory DiscountModel.fromJson(Map<String, dynamic> json) =>
      _$DiscountModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiscountModelToJson(this);
}
