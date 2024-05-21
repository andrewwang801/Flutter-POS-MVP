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
class KitchenData {
  KitchenData({required this.reprintArray});

  final List<List<String>> reprintArray;
}

// state
class KitchenState extends Equatable {
  KitchenState({this.failiure, required this.workable, this.kitchenData});

  final KitchenData? kitchenData;
  final Failiure? failiure;
  final Workable workable;

  @override
  List<Object?> get props => [workable, failiure];

  KitchenState copyWith(
      {Failiure? failiure, required Workable? workable, KitchenData? data}) {
    return KitchenState(
        failiure: failiure ?? this.failiure,
        workable: workable ?? this.workable,
        kitchenData: data ?? kitchenData);
  }
}
