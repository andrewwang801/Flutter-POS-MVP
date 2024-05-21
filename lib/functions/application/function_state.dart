import 'package:equatable/equatable.dart';

import '../model/function_model.dart';

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
class FunctionData {
  FunctionData({required this.functionList});

  final List<FunctionModel> functionList;
}

// state
class FunctionState extends Equatable {
  FunctionState({this.failiure, this.workable, this.data});

  final FunctionData? data;
  final Failiure? failiure;
  final Workable? workable;

  @override
  List<Object?> get props => [workable, failiure];

  FunctionState copyWith(
      {Failiure? failiure, Workable? workable, FunctionData? data}) {
    return FunctionState(
        failiure: failiure ?? this.failiure,
        workable: workable ?? this.workable,
        data: data ?? data);
  }
}
