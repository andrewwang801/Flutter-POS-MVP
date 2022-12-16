import 'package:equatable/equatable.dart';

import '../model/table_data_model.dart';

abstract class TableState extends Equatable {
  @override
  List<Object?> get props => [];
}

enum NOTIFY_TYPE {
  SHOW_COVER,
  GOTO_TABLE_LAYOUT,
  GOTO_MAIN,
  COVER_SELECT_ERROR,
  NONE,
}

class TableInitialState extends TableState {}

class TableLoadingState extends TableState {}

class TableSuccessState extends TableState {
  TableSuccessState(
      {required this.tableList, required this.notify_type, this.errMsg});
  final List<TableDataModel> tableList;
  final NOTIFY_TYPE notify_type;
  final String? errMsg;

  TableSuccessState copyWith(
      {List<TableDataModel>? tableList,
      NOTIFY_TYPE? notify_type,
      String? errMsg}) {
    return TableSuccessState(
        tableList: tableList ?? this.tableList,
        notify_type: notify_type ?? this.notify_type,
        errMsg: errMsg ?? this.errMsg);
  }
}

class TableErrorState extends TableState {
  TableErrorState(this.errMsg);

  final String errMsg;
}
