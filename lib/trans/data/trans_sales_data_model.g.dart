// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trans_sales_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransSalesData _$TransSalesDataFromJson(Map<String, dynamic> json) =>
    TransSalesData(
      json['RcptNo'] as String,
      json['TableNo'] as String,
      json['OperatorName'] as String,
      (json['GTotal'] as num?)?.toDouble(),
      json['Open_Date'] as String,
      json['Open_Time'] as String,
      json['Close_Date'] as String?,
      json['Close_Time'] as String?,
      json['TransMode'] as String,
      json['POSID'] as String,
      json['SalesNo'] as int,
      json['SplitNo'] as int,
      json['Covers'] as int,
      json['TransStatus'] as String?,
    );

Map<String, dynamic> _$TransSalesDataToJson(TransSalesData instance) =>
    <String, dynamic>{
      'RcptNo': instance.rcptNo,
      'TableNo': instance.tableNo,
      'OperatorName': instance.firstOp,
      'GTotal': instance.total,
      'Open_Date': instance.openDate,
      'Open_Time': instance.openTime,
      'Close_Date': instance.closeDate,
      'Close_Time': instance.closeTime,
      'TransMode': instance.transMode,
      'POSID': instance.posID,
      'SalesNo': instance.salesNo,
      'SplitNo': instance.splitNo,
      'Covers': instance.covers,
      'TransStatus': instance.transStatus,
    };
