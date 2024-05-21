// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prep_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrepModel _$PrepModelFromJson(Map<String, dynamic> json) => PrepModel(
      json['number'] as String?,
      json['name'] as String?,
    )..quantity = json['quantity'] as int?;

Map<String, dynamic> _$PrepModelToJson(PrepModel instance) => <String, dynamic>{
      'number': instance.number,
      'name': instance.name,
      'quantity': instance.quantity,
    };
