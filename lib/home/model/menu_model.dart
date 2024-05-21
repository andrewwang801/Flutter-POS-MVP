import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'menu_model.g.dart';

@JsonSerializable()
class MenuModel extends Equatable {
  final int MenuID;
  final String? MenuName;
  final String? MenuName_Chinese;
  final int? MActive;
  final String? RGBColour;
  final int? KPosition;
  final int? DisplayImage;
  final String? ImageName;

  MenuModel(this.MenuID,
      [this.MenuName,
      this.MenuName_Chinese,
      this.MActive,
      this.RGBColour,
      this.KPosition,
      this.DisplayImage,
      this.ImageName]);

  @override
  List<Object?> get props => [this.MenuID];

  factory MenuModel.fromJson(Map<String, dynamic> json) =>
      _$MenuModelFromJson(json);
  Map<String, dynamic> toJson() => _$MenuModelToJson(this);
}

final List<MenuModel> menus = [];
