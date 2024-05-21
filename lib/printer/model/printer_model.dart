import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'printer_model.g.dart';

@JsonSerializable()
class PrinterModel extends Equatable {
  @JsonKey(name: 'PrinterID')
  int printerID;
  @JsonKey(name: 'PrinterType')
  String printerType;
  @JsonKey(name: 'PrinterDeviceName')
  String printerDeviceName;
  @JsonKey(name: 'Address')
  String address;
  @JsonKey(name: 'Port')
  int port;
  @JsonKey(name: 'InterfaceType')
  int interfaceType;

  PrinterModel({
    required this.printerID,
    required this.printerType,
    required this.printerDeviceName,
    required this.address,
    required this.port,
    required this.interfaceType,
  });

  factory PrinterModel.fromJson(Map<String, dynamic> json) =>
      _$PrinterModelFromJson(json);
  Map<String, dynamic> toJson() => _$PrinterModelToJson(this);

  @override
  List<Object?> get props => [];
}
