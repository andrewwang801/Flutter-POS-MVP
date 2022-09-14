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
  Data(
      {required this.widgets,
      this.date1,
      this.time1,
      this.date2,
      this.time2,
      required this.salesReport});

  final String? salesReport;
  final String? date1;
  final String? time1;
  final String? date2;
  final String? time2;
  final List<Widget> widgets;
}

class SalesReportState extends Equatable {
  const SalesReportState({this.workable, this.failure, this.data});

  final Workable? workable;
  final Failure? failure;
  final Data? data;

  SalesReportState copyWith(
      {Workable? workable, Failure? failure, Data? data}) {
    return SalesReportState(
        workable: workable ?? this.workable,
        failure: failure ?? this.failure,
        data: data ?? this.data);
  }

  @override
  List<Object?> get props => [workable, failure, data];
}
