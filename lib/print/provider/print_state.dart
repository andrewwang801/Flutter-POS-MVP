import 'package:equatable/equatable.dart';

abstract class PrintState extends Equatable {
  @override
  List<Object?> get props => <Object>[];
}

class PrintInitialState extends PrintState {}

class PrintLoadingState extends PrintState {}

class PrintSuccessState extends PrintState {}

class PrintErrorState extends PrintState {
  PrintErrorState({required this.errMsg});

  final String errMsg;
}
