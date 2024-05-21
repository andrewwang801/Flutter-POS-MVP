import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'printer_support_model.g.dart';

@JsonSerializable()
class PrinterSupportModel extends Equatable {
  PrinterSupportModel(
      this.id, this.printerModel, this.recLineChar, this.recLineWidth);

  @JsonKey(name: 'Id')
  final int id;
  @JsonKey(name: 'PrinterModel')
  final String printerModel;
  @JsonKey(name: 'RecLineChar')
  final int recLineChar;
  @JsonKey(name: 'RecLineWidth')
  final int recLineWidth;

  factory PrinterSupportModel.fromJson(Map<String, dynamic> json) =>
      _$PrinterSupportModelFromJson(json);
  Map<String, dynamic> toJson() => _$PrinterSupportModelToJson(this);

  @override
  List<Object?> get props => [];
}
