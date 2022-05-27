import 'package:json_annotation/json_annotation.dart';

part 'menu_item_model.g.dart';

@JsonSerializable()
class MenuItemModel {
  @JsonKey(name: 'MenuID')
  final int? menuID;
  @JsonKey(name: 'PLUNumber')
  final String? pluNumber;
  @JsonKey(name: 'SMenuID')
  final int? sMenuID;
  @JsonKey(name: 'ItemName')
  final String? itemName;
  @JsonKey(name: 'ItemName_Chinese')
  final String? itemNameCn;
  @JsonKey(name: 'RGBColour')
  final String? color;
  @JsonKey(name: 'KPosition')
  final int? kPosition;
  @JsonKey(name: 'ItemType')
  final String? itemType;
  @JsonKey(name: 'SetMenuQty')
  final double? setMenuQty;

  MenuItemModel(
      this.menuID,
      this.pluNumber,
      this.sMenuID,
      this.itemName,
      this.itemNameCn,
      this.color,
      this.kPosition,
      this.itemType,
      this.setMenuQty);

  factory MenuItemModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemModelToJson(this);
}
