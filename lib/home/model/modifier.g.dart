// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modifier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModifierModel _$ModifierModelFromJson(Map<String, dynamic> json) =>
    ModifierModel(
      json['msgid'] as int?,
      json['message'] as String?,
      json['message_chinese'] as String?,
      json['RGBColour'] as String?,
      json['DisplayImage'] as int?,
      json['ImageName'] as String?,
    );

Map<String, dynamic> _$ModifierModelToJson(ModifierModel instance) =>
    <String, dynamic>{
      'msgid': instance.msgId,
      'message': instance.message,
      'message_chinese': instance.messageCh,
      'RGBColour': instance.rgbColour,
      'DisplayImage': instance.displayImage,
      'ImageName': instance.imageName,
    };
