import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'modifier.g.dart';

@JsonSerializable()
class ModifierModel extends Equatable {
  @JsonKey(name: 'msgid')
  final int? msgId;
  @JsonKey(name: 'message')
  final String? message;
  @JsonKey(name: 'message_chinese')
  final String? messageCh;
  @JsonKey(name: 'RGBColour')
  final String? rgbColour;
  @JsonKey(name: 'DisplayImage')
  final int? displayImage;
  @JsonKey(name: 'ImageName')
  final String? imageName;

  ModifierModel(this.msgId, this.message, this.messageCh, this.rgbColour,
      this.displayImage, this.imageName);

  factory ModifierModel.fromJson(Map<String, dynamic> json) =>
      _$ModifierModelFromJson(json);
  Map<String, dynamic> toJson() => _$ModifierModelToJson(this);
  @override
  List<Object?> get props => [];
}
