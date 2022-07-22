import 'package:injectable/injectable.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../common/GlobalConfig.dart';
import '../../common/helper/db_helper.dart';
import '../../common/utils/type_util.dart';
import '../model/table_data_model.dart';
import 'i_tablemangement_repository.dart';

@Injectable(as: ITableMangementRepository)
class LocalTableManagementRepository extends ITableMangementRepository
    with TypeUtil {
  LocalTableManagementRepository(this.dbHelper);
  final LocalDBHelper dbHelper;

  @override
  Future<int> getCountTableNo(String tableNo) async {
    final String query =
        "SELECT COUNT(*) FROM HeldTables WHERE TableNo = '$tableNo'";

    final Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      return dynamicToInt(maps[0].values.elementAt(0));
    }
    return 0;
  }

  @override
  Future<List<TableDataModel>> getTableLayoutData(int section) async {
    final String query =
        'SELECT TBLNo, TBLStatus FROM TblLayout WHERE SectionID = $section';

    final Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((e) {
      return TableDataModel(
          e.values.elementAt(0).toString(), e.values.elementAt(1).toString());
    }).toList();
  }

  @override
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
      String salesAreaID) async {
    String query =
        'INSERT INTO HeldTables(POSID, SalesNo, SplitNo, OperatorNo, TableNo, Covers, TransMode, TransStatus, Open_Date, Open_Time, RcptNo, SalesAreaID, OperatornoFirst)';
    final String values =
        " VALUES ( '$posID', $salesNo, $splitNo, $operatorNo, '$tableNo', $covers, '${GlobalConfig.TransMode}', ' ', '$sDate', '$sTime', '$rcptNo', '$salesAreaID', $operatorNo )";
    query += values;

    final Database db = await dbHelper.database;
    await db.rawQuery(query);
  }

  @override
  Future<void> updateTableStatus(String tableNo) async {
    final Database db = await dbHelper.database;
    final String query =
        "UPDATE TblLayout SET TBLStatus = 'O' WHERE TBLNo IN (SELECT TableNo FROM HeldTables WHERE TableNo = '$tableNo')";
    await db.rawQuery(query);
  }

  // global db handler
  @override
  Future<List<List<String>>> getRcptNo() async {
    List<List<String>> rcptNoList = <List<String>>[];
    String query = 'SELECT * FROM RcptNoCtrl';

    Database db = await dbHelper.database;
    List<Map<String, dynamic>> maps = await db.rawQuery(query);

    for (Map<String, dynamic> item in maps) {
      List<String> rcptNo = <String>[];
      rcptNo.add(item[0].toString());
      rcptNo.add(item[1].toString());
      rcptNo.add(item[2].toString());
      rcptNoList.add(rcptNo);
    }
    return rcptNoList;
  }

  @override
  Future<void> updateRcptNoCtrl(
      String tempRcptNo, String dateTime, int status) async {
    Database db = await dbHelper.database;
    String query = '';
    if (status == 1) {
      query = "UPDATE RcptNoCtrl SET RcptHdr = '$tempRcptNo'";
    } else if (status == 2) {
      query =
          "INSERT INTO RcptNoCtrl (RcptHdr, RcptCtrlDate) VALUES ( '$tempRcptNo', '$dateTime' )";
    } else if (status == 3) {
      query = "UPDATE RcptNoCtrl SET NxtRcptNo = '$tempRcptNo'";
    } else if (status == 4) {
      query = "INSERT INTO RcptNoCtrl (NxtRcptNo) VALUES ('$tempRcptNo')";
    }
    await db.rawQuery(query);
  }

  @override
  Future<int> getSNoCtrl() async {
    Database db = await dbHelper.database;
    String query = 'SELECT IFNULL(LastSalesNo, 0) FROM SNoCtrl';
    List<Map<String, dynamic>> maps = await db.rawQuery(query);
    if (maps.isNotEmpty) {
      return dynamicToInt(maps[0].values.elementAt(0));
    }
    return 0;
  }

  @override
  Future<void> updateSalesNo(int salesNo) async {
    String query = 'UPDATE SNoCtrl SET LastSalesNo = $salesNo';
    Database db = await dbHelper.database;
    await db.rawQuery(query);
  }

  @override
  Future<void> insertRcptDlts(String rcptNo, int salesNo, int splitNo,
      String tableNo, int operatorNo) async {
    String query =
        'INSERT INTO RcptDtls(ReceiptNo, OperatorNo, TableNo, SalesNo, SplitNo, Finalized, Printed, Void, TaxExempt, CopyNo)';
    String values =
        " VALUES ( '$rcptNo', $operatorNo, '$tableNo', $salesNo, $splitNo, 1, 0, 0, 0, 0 )";
    query += values;

    final Database db = await dbHelper.database;
    await db.rawQuery(query);
  }
}
