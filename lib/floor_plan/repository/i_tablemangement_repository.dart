// ignore_for_file: prefer_relative_imports

import 'package:raptorpos/floor_plan/model/table_data_model.dart';

abstract class ITableMangementRepository {
  Future<List<TableDataModel>> getTableLayoutData(int section);
  Future<int> getCountTableNo(String tableNo);
  Future<void> insertHeldTable(
      String posID,
      int salesNo,
      int splitNo,
      int operatorNo,
      String tableNo,
      int covers,
      String sDate,
      String sTime,
      String rcptNo,
      String salesAreaID);
  Future<void> updateTableStatus(String tableNo);

  // global db handler
  Future<List<List<String>>> getRcptNo();
  Future<void> updateRcptNoCtrl(String tempRcptNo, String dateTime, int status);
  Future<int> getSNoCtrl();
  Future<void> updateSalesNo(int salesNo);
  Future<void> insertRcptDlts(
      String rcptNo, int salesNo, int splitNo, String tableNo, int operatorNo);
}
