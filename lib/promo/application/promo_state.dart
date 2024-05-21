import 'package:equatable/equatable.dart';

import '../../common/extension/workable.dart';

// common part
class Failiure {
  Failiure({required this.errMsg});

  final String errMsg;
}
//end of common part

// data class
class PromoData {
  PromoData();
}

// state
class PromoState extends Equatable {
  PromoState({this.failiure, this.workable, this.data});

  final PromoData? data;
  final Failiure? failiure;
  final Workable? workable;

  @override
  List<Object?> get props => [workable, failiure];

  PromoState copyWith(
      {Failiure? failiure, Workable? workable, PromoData? data}) {
    return PromoState(
        failiure: failiure ?? this.failiure,
        workable: workable ?? this.workable,
        data: data ?? data);
  }
}
