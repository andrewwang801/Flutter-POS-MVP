import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'function_model.g.dart';

@JsonSerializable()
class FunctionModel extends Equatable {
  FunctionModel(this.functionID, this.title, this.subFunctionID);

  @JsonKey(name: 'FunctionID')
  final int functionID;
  @JsonKey(name: 'Title')
  final String title;
  @JsonKey(name: 'SubFunctionID')
  final int subFunctionID;
  @override
  List<Object?> get props => [];

  factory FunctionModel.fromJson(Map<String, dynamic> json) =>
      _$FunctionModelFromJson(json);

  Map<String, dynamic> toJson() => _$FunctionModelToJson(this);
}
