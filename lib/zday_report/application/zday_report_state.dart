import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum Workable { initial, loading, ready, failure }

extension WorkableX on Workable {
  bool get isInitial => this == Workable.initial;
  bool get isLoading => this == Workable.loading;
  bool get isReady => this == Workable.ready;
  bool get isFailure => this == Workable.failure;
}

class Failure {
  Failure({required this.errMsg});

  final String errMsg;
}

class Data {
  Data({required this.zDayWidgets, required this.zDayReport});

  final String? zDayReport;
  final List<Widget> zDayWidgets;
}

class ZDayReportState extends Equatable {
  const ZDayReportState({this.workable, this.failure, this.data});

  final Workable? workable;
  final Failure? failure;
  final Data? data;

  ZDayReportState copyWith({Workable? workable, Failure? failure, Data? data}) {
    return ZDayReportState(
        workable: workable ?? this.workable,
        failure: failure ?? this.failure,
        data: data ?? this.data);
  }

  @override
  List<Object?> get props => [workable, failure, data];
}
