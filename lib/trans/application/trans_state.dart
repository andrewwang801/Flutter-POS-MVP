import 'package:equatable/equatable.dart';

import '../data/trans_sales_data_model.dart';

enum Operation { NONE, KITCHEN_REPRINT, REFUND }
// common part
enum Workable { initial, loading, ready, failure }

extension WorkableX on Workable {
  bool get isInitial => this == Workable.initial;
  bool get isLoading => this == Workable.loading;
  bool get isReady => this == Workable.ready;
  bool get isFailure => this == Workable.failure;
}

class Failiure {
  Failiure({required this.errMsg});

  final String errMsg;
}
//end of common part

// data class
class TransData {
  TransData({required this.transArrayClosed, required this.transArrayOpened});

  final List<TransSalesData> transArrayClosed;
  final List<TransSalesData> transArrayOpened;
}

// state
class TransState extends Equatable {
  TransState(
      {this.failiure,
      this.workable,
      this.operation = Operation.NONE,
      this.transData});

  final TransData? transData;
  final Failiure? failiure;
  final Workable? workable;
  final Operation? operation;

  @override
  List<Object?> get props => [workable, failiure];

  TransState copyWith(
      {Failiure? failiure,
      Workable? workable,
      Operation? operation,
      TransData? data}) {
    return TransState(
        failiure: failiure ?? this.failiure,
        workable: workable ?? this.workable,
        operation: operation ?? this.operation,
        transData: data ?? transData);
  }
}
