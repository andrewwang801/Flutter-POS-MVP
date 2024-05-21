import 'package:equatable/equatable.dart';

abstract class PrinterState extends Equatable {
  @override
  List<Object?> get props => <Object>[];
}

class PrinterInitialState extends PrinterState {}

class PrinterLoadingState extends PrinterState {}

class PrinterSuccessState extends PrinterState {}

class PrinterErrorState extends PrinterState {}
