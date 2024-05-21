// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'function_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FunctionModel _$FunctionModelFromJson(Map<String, dynamic> json) =>
    FunctionModel(
      json['FunctionID'] as int,
      json['Title'] as String,
      json['SubFunctionID'] as int,
    );

Map<String, dynamic> _$FunctionModelToJson(FunctionModel instance) =>
    <String, dynamic>{
      'FunctionID': instance.functionID,
      'Title': instance.title,
      'SubFunctionID': instance.subFunctionID,
    };
