// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuModel _$MenuModelFromJson(Map<String, dynamic> json) => MenuModel(
      json['MenuID'] as int,
      json['MenuName'] as String?,
      json['MenuName_Chinese'] as String?,
      json['MActive'] as int?,
      json['RGBColour'] as String?,
      json['KPosition'] as int?,
      json['DisplayImage'] as int?,
      json['ImageName'] as String?,
    );

Map<String, dynamic> _$MenuModelToJson(MenuModel instance) => <String, dynamic>{
      'MenuID': instance.MenuID,
      'MenuName': instance.MenuName,
      'MenuName_Chinese': instance.MenuName_Chinese,
      'MActive': instance.MActive,
      'RGBColour': instance.RGBColour,
      'KPosition': instance.KPosition,
      'DisplayImage': instance.DisplayImage,
      'ImageName': instance.ImageName,
    };
