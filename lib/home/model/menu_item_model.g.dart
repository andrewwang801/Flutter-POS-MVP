// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItemModel _$MenuItemModelFromJson(Map<String, dynamic> json) =>
    MenuItemModel(
      json['MenuID'] as int?,
      json['PLUNumber'] as String?,
      json['ItemName'] as String?,
      json['ItemName_Chinese'] as String?,
      json['KPosition'] as int?,
      json['RGBColour'] as String?,
      (json['Sell1'] as num?)?.toDouble(),
      json['PLUsoldout'] as int?,
      json['DisplayImage'] as int?,
      json['imagename'] as String?,
    );

Map<String, dynamic> _$MenuItemModelToJson(MenuItemModel instance) =>
    <String, dynamic>{
      'MenuID': instance.menuID,
      'PLUNumber': instance.pluNumber,
      'ItemName': instance.itemName,
      'ItemName_Chinese': instance.itemNameCh,
      'KPosition': instance.kPosition,
      'RGBColour': instance.rgbColour,
      'Sell1': instance.price,
      'PLUsoldout': instance.pluSoldOut,
      'DisplayImage': instance.pluImage,
      'imagename': instance.imageName,
    };
