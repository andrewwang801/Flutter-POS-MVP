import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trans_sales_data_model.g.dart';

@JsonSerializable()
class TransSalesData extends Equatable {
  TransSalesData(
      this.rcptNo,
      this.tableNo,
      this.firstOp,
      this.total,
      this.openDate,
      this.openTime,
      this.closeDate,
      this.closeTime,
      this.transMode,
      this.posID,
      this.salesNo,
      this.splitNo,
      this.covers,
      this.transStatus);

  @JsonKey(name: 'RcptNo')
  final String? rcptNo;
  @JsonKey(name: 'TableNo')
  final String tableNo;
  @JsonKey(name: 'OperatorName')
  final String firstOp;
  @JsonKey(name: 'GTotal')
  final double? total;
  @JsonKey(name: 'Open_Date')
  final String openDate;
  @JsonKey(name: 'Open_Time')
  final String openTime;
  @JsonKey(name: 'Close_Date')
  final String? closeDate;
  @JsonKey(name: 'Close_Time')
  final String? closeTime;
  @JsonKey(name: 'TransMode')
  final String transMode;
  @JsonKey(name: 'POSID')
  final String posID;
  @JsonKey(name: 'SalesNo')
  final int salesNo;
  @JsonKey(name: 'SplitNo')
  final int splitNo;
  @JsonKey(name: 'Covers')
  final int covers;
  @JsonKey(name: 'TransStatus')
  final String? transStatus;

  factory TransSalesData.fromJson(Map<String, dynamic> json) =>
      _$TransSalesDataFromJson(json);
  Map<String, dynamic> toJson() => _$TransSalesDataToJson(this);

  @override
  List<Object?> get props => [];
}
