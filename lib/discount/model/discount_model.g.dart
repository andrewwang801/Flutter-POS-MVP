// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscountModel _$DiscountModelFromJson(Map<String, dynamic> json) =>
    DiscountModel(
      json['Title'] as String,
      json['FunctionID'] as int,
      json['SubFunctionID'] as int,
      json['Feature'] as int,
      json['Parameter'] as String,
      json['disc_remarks'] as int,
      json['CoverBased'] as int,
      json['CoverBasedType'] as String,
      json['RGBColour'] as String?,
    );

Map<String, dynamic> _$DiscountModelToJson(DiscountModel instance) =>
    <String, dynamic>{
      'Title': instance.discTitle,
      'FunctionID': instance.fnctnID,
      'SubFunctionID': instance.subFnID,
      'Feature': instance.fnFeature,
      'Parameter': instance.fnParm,
      'disc_remarks': instance.disc_remarks,
      'CoverBased': instance.coverBased,
      'CoverBasedType': instance.coverbasedtype,
      'RGBColour': instance.color,
    };
