// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesCategoryModel _$SalesCategoryModelFromJson(Map<String, dynamic> json) =>
    SalesCategoryModel(
      json['CategoryName'] as String?,
      json['CategoryID'] as int,
      json['CategoryName_Chinese'] as String?,
    );

Map<String, dynamic> _$SalesCategoryModelToJson(SalesCategoryModel instance) =>
    <String, dynamic>{
      'CategoryName': instance.name,
      'CategoryName_Chinese': instance.name_ch,
      'CategoryID': instance.id,
    };
