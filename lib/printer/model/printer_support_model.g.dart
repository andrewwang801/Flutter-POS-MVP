// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer_support_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrinterSupportModel _$PrinterSupportModelFromJson(Map<String, dynamic> json) =>
    PrinterSupportModel(
      json['Id'] as int,
      json['PrinterModel'] as String,
      json['RecLineChar'] as int,
      json['RecLineWidth'] as int,
    );

Map<String, dynamic> _$PrinterSupportModelToJson(
        PrinterSupportModel instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'PrinterModel': instance.printerModel,
      'RecLineChar': instance.recLineChar,
      'RecLineWidth': instance.recLineWidth,
    };
