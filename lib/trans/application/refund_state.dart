import 'package:equatable/equatable.dart';

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
class RefundData {
  RefundData({required this.refundArray});

  final List<List<String>> refundArray;
}

// state
class RefundState extends Equatable {
  RefundState({this.failiure, required this.workable, this.refundData});

  final RefundData? refundData;
  final Failiure? failiure;
  final Workable workable;

  @override
  List<Object?> get props => [workable, failiure];

  RefundState copyWith(
      {Failiure? failiure, required Workable? workable, RefundData? data}) {
    return RefundState(
        failiure: failiure ?? this.failiure,
        workable: workable ?? this.workable,
        refundData: data ?? refundData);
  }
}
