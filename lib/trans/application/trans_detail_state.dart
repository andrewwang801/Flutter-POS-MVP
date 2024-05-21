import 'package:equatable/equatable.dart';

import '../data/trans_sales_data_model.dart';

enum Operation { NONE, BILL_ADJUST, CHECK_BILL }
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
class TransDetailData {
  TransDetailData({required this.transDetail, required this.billAdjArray});

  final List<List<String>> transDetail;
  final List<List<String>> billAdjArray;
}

// state
class TransDetailState extends Equatable {
  TransDetailState(
      {this.failiure,
      this.workable,
      this.operation = Operation.NONE,
      this.transData});

  final TransDetailData? transData;
  final Failiure? failiure;
  final Workable? workable;
  final Operation? operation;

  @override
  List<Object?> get props => [workable, failiure];

  TransDetailState copyWith(
      {Failiure? failiure,
      Workable? workable,
      Operation? operation,
      TransDetailData? data}) {
    return TransDetailState(
        failiure: failiure ?? this.failiure,
        workable: workable ?? this.workable,
        operation: operation ?? this.operation,
        transData: data ?? transData);
  }
}
