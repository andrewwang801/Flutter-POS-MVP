// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrinterModel _$PrinterModelFromJson(Map<String, dynamic> json) => PrinterModel(
      printerID: json['PrinterID'] as int,
      printerType: json['PrinterType'] as String,
      printerDeviceName: json['PrinterDeviceName'] as String,
      address: json['Address'] as String,
      port: json['Port'] as int,
      interfaceType: json['InterfaceType'] as int,
    );

Map<String, dynamic> _$PrinterModelToJson(PrinterModel instance) =>
    <String, dynamic>{
      'PrinterID': instance.printerID,
      'PrinterType': instance.printerType,
      'PrinterDeviceName': instance.printerDeviceName,
      'Address': instance.address,
      'Port': instance.port,
      'InterfaceType': instance.interfaceType,
    };
