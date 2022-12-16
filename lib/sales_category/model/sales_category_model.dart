import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sales_category_model.g.dart';

@JsonSerializable()
class SalesCategoryModel extends Equatable {
  const SalesCategoryModel(this.name, this.id, this.name_ch);
  factory SalesCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$SalesCategoryModelFromJson(json);

  @JsonKey(name: 'CategoryName')
  final String? name;
  @JsonKey(name: 'CategoryName_Chinese')
  final String? name_ch;
  @JsonKey(name: 'CategoryID')
  final int id;
  @override
  List<Object?> get props => <Object>[];

  Map<String, dynamic> toJson() => _$SalesCategoryModelToJson(this);
}
