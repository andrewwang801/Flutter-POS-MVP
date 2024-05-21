import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'promotion_model.g.dart';

@JsonSerializable()
class PromotionModel extends Equatable {
  const PromotionModel(this.name, this.id);
  factory PromotionModel.fromJson(Map<String, dynamic> json) =>
      _$PromotionModelFromJson(json);

  final String name;
  final int id;
  @override
  List<Object?> get props => <Object>[];

  Map<String, dynamic> toJson() => _$PromotionModelToJson(this);
}
