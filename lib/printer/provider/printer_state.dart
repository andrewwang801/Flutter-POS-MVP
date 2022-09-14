import 'package:equatable/equatable.dart';

import '../model/printer_model.dart';
import '../model/printer_support_model.dart';

enum OPERATION {
  FETCH,
  ADD,
  UPDATE,
  DELETE,
  CONNECT_SUCCESS,
  CONNECT_FAIL,
  DISCONNECT_SUCCESS,
  DISCONNECT_FAIL
}

abstract class PrinterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PrinterInitialState extends PrinterState {}

class PrinterLoadingState extends PrinterState {}

class PrinterSuccessState extends PrinterState {
  PrinterSuccessState(
      {this.message,
      required this.printers,
      required this.printerSupportList,
      required this.operation});

  final List<PrinterModel> printers;
  final List<PrinterSupportModel> printerSupportList;
  final OPERATION operation;
  final String? message;

  PrinterSuccessState copyWith(
      {List<PrinterModel>? printers,
      List<PrinterSupportModel>? printerSupportList,
      OPERATION? operation,
      String? message}) {
    return PrinterSuccessState(
        printers: printers ?? this.printers,
        printerSupportList: printerSupportList ?? this.printerSupportList,
        operation: operation ?? this.operation,
        message: message ?? this.message);
  }
}

class PrinterErrorState extends PrinterState {
  PrinterErrorState(this.errMsg);

  final String errMsg;
}
