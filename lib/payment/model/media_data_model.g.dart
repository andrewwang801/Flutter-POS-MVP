// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaData _$MediaDataFromJson(Map<String, dynamic> json) => MediaData(
      funcID: json['funcID'] as int,
      title: json['title'] as String,
      titleChinese: json['titleChinese'] as String,
      subFuncID: json['subFuncID'] as int,
      tenderValue: (json['tenderValue'] as num).toDouble(),
      minimum: (json['minimum'] as num).toDouble(),
      maximum: (json['maximum'] as num).toDouble(),
      propForCustID: json['propForCustID'] as bool,
      printSignature: json['printSignature'] as bool,
      applyTax: json['applyTax'] as bool,
    );

Map<String, dynamic> _$MediaDataToJson(MediaData instance) => <String, dynamic>{
      'funcID': instance.funcID,
      'title': instance.title,
      'titleChinese': instance.titleChinese,
      'subFuncID': instance.subFuncID,
      'tenderValue': instance.tenderValue,
      'minimum': instance.minimum,
      'maximum': instance.maximum,
      'propForCustID': instance.propForCustID,
      'printSignature': instance.printSignature,
      'applyTax': instance.applyTax,
    };
