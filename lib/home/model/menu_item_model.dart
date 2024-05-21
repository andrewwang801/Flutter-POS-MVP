import 'package:json_annotation/json_annotation.dart';

part 'menu_item_model.g.dart';
//PLUNumber ItemName, ItemName_Chinese, KPosition, RGBColour, Sell1, PLUsoldout, DisplayImage, imagename

@JsonSerializable()
class MenuItemModel {
  // @JsonKey(name: 'MenuID')
  // final int? menuID;
  // @JsonKey(name: 'PLUNumber')
  // final String? pluNumber;
  // @JsonKey(name: 'SMenuID')
  // final int? sMenuID;
  // @JsonKey(name: 'ItemName')
  // final String? itemName;
  // @JsonKey(name: 'ItemName_Chinese')
  // final String? itemNameCn;
  // @JsonKey(name: 'RGBColour')
  // final String? color;
  // @JsonKey(name: 'KPosition')
  // final int? kPosition;
  // @JsonKey(name: 'ItemType')
  // final String? itemType;
  // @JsonKey(name: 'SetMenuQty')
  // final double? setMenuQty;

  @JsonKey(name: 'MenuID')
  final int? menuID;
  @JsonKey(name: 'PLUNumber')
  final String? pluNumber;
  @JsonKey(name: 'ItemName')
  final String? itemName;
  @JsonKey(name: 'ItemName_Chinese')
  final String? itemNameCh;
  @JsonKey(name: 'KPosition')
  final int? kPosition;
  @JsonKey(name: 'RGBColour')
  final String? rgbColour;
  @JsonKey(name: 'Sell1')
  final double? price;
  @JsonKey(name: 'PLUsoldout')
  final int? pluSoldOut;
  @JsonKey(name: 'DisplayImage')
  final int? pluImage;
  @JsonKey(name: 'imagename')
  final String? imageName;

  MenuItemModel(
    this.menuID,
    this.pluNumber,
    this.itemName,
    this.itemNameCh,
    this.kPosition,
    this.rgbColour,
    this.price,
    this.pluSoldOut,
    this.pluImage,
    this.imageName,
  );

  factory MenuItemModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemModelToJson(this);
}
