// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItemModel _$MenuItemModelFromJson(Map<String, dynamic> json) =>
    MenuItemModel(
      json['MenuID'] as int?,
      json['PLUNumber'] as String?,
      json['SMenuID'] as int?,
      json['ItemName'] as String?,
      json['ItemName_Chinese'] as String?,
      json['RGBColour'] as String?,
      json['KPosition'] as int?,
      json['ItemType'] as String?,
      (json['SetMenuQty'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MenuItemModelToJson(MenuItemModel instance) =>
    <String, dynamic>{
      'MenuID': instance.menuID,
      'PLUNumber': instance.pluNumber,
      'SMenuID': instance.sMenuID,
      'ItemName': instance.itemName,
      'ItemName_Chinese': instance.itemNameCn,
      'RGBColour': instance.color,
      'KPosition': instance.kPosition,
      'ItemType': instance.itemType,
      'SetMenuQty': instance.setMenuQty,
    };
