import 'package:injectable/injectable.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../common/GlobalConfig.dart';
import '../../common/helper/db_helper.dart';
import '../../common/utils/datetime_util.dart';
import '../../common/utils/type_util.dart';
import '../model/table_data_model.dart';
import 'i_tablemangement_repository.dart';
import '../../common/extension/string_extension.dart';

@Injectable(as: ITableMangementRepository)
class LocalTableManagementRepository extends ITableMangementRepository
    with TypeUtil, DateTimeUtil {
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
  Future<void> updateTableStatusToO(String tableNo) async {
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
      rcptNo.add(item.values.elementAt(0).toString());
      rcptNo.add(item.values.elementAt(1).toString());
      rcptNo.add(item.values.elementAt(2).toString());
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

  @override
  Future<void> updateTableStatus(String tableNo, String status) async {
    String query =
        "UPDATE TblLayout SET TBLStatus = '$status' WHERE TBLNo IN (SELECT TableNo FROM HeldTables WHERE TableNo = '$tableNo')";
    final Database db = await dbHelper.database;
    await db.rawQuery(query);
  }

  @override
  Future<List<String>> getReceiptNumber(
      int salesOnTmpServer, String deviceNo) async {
    String year = currentDateTime('yy');
    String dateTIme = currentDateTime('yyyy-MM-dd HH:mm:ss.0');

    String nxtRcptNo = '000000000000';
    String msgBox = '';
    int maxRcptNo = 0;
    String rcptCtrlDate = '';
    String rcptHdr = '';
    String tempRcptNo = '';
    int flag = 0;

    if (salesOnTmpServer == 0) {
      List<List<String>> rcptNoList = await getRcptNo();
      if (rcptNoList.isNotEmpty) {
        nxtRcptNo = rcptNoList[0][0];
        rcptCtrlDate = rcptNoList[0][1];
        rcptHdr = rcptNoList[0][2];
        String headerRcpt = '';
        if (rcptHdr.isNotEmpty) headerRcpt = rcptHdr.substring(1);

        if (year == headerRcpt) {
          maxRcptNo = nxtRcptNo.substring(3).toInt();
          tempRcptNo = nxtRcptNo.substring(0, 3);
        } else {
          maxRcptNo = 0;
          tempRcptNo = nxtRcptNo.substring(0, 1) + year;
          await updateRcptNoCtrl(tempRcptNo, '', 1);
        }
      } else {
        tempRcptNo = 'A$year';
        maxRcptNo = 0;
        await updateRcptNoCtrl(tempRcptNo, dateTIme, 2);
      }
      if (maxRcptNo == 999999998) {
        msgBox =
            'Please change the receipt header to next alphabet before you settle next bill';
      } else if (maxRcptNo == 999999999) {
        msgBox = 'Please change the receipt header to next alphabet';
      } else {
        maxRcptNo = 1000000001 + maxRcptNo;
        String rcptNo = maxRcptNo.toString();
        String srcptNo = rcptNo.substring(1);

        nxtRcptNo = tempRcptNo + srcptNo;
        await updateRcptNoCtrl(nxtRcptNo, '', 3);
      }
    } else {
      tempRcptNo = deviceNo.substring(4) +
          dateTIme.substring(0, 2) +
          dateTIme.substring(2, 4) +
          year;
      flag = 0;
      List<List<String>> rcptNoList = await getRcptNo();
      if (rcptNoList.isNotEmpty) {
        nxtRcptNo = rcptNoList[0][0];
        rcptCtrlDate = rcptNoList[0][1];
        rcptHdr = rcptNoList[0][2];

        if (tempRcptNo == nxtRcptNo.substring(0, 8)) {
          String rcptr = nxtRcptNo.substring(8);
          maxRcptNo = rcptr.toInt();
        } else {
          maxRcptNo = 0;
        }
      } else {
        flag = 1;
        maxRcptNo = 0;
      }

      if (maxRcptNo == 9998) {
        msgBox = 'Please download sales to server before you settle next bill';
      } else if (maxRcptNo == 9999) {
        msgBox = 'Please download sales to server';
      } else {
        maxRcptNo = 10001 + maxRcptNo;
        String rcptNo = maxRcptNo.toString();
        String srcptNo = rcptNo.substring(1);
        nxtRcptNo = tempRcptNo + srcptNo;

        if (flag == 1) {
          await updateRcptNoCtrl(nxtRcptNo, '', 4);
        } else {
          await updateRcptNoCtrl(nxtRcptNo, '', 3);
        }
      }
    }
    final List<String> rcptList = <String>[nxtRcptNo, msgBox];
    return rcptList;
  }

  @override
  Future<int> getSalesNumber() async {
    int salesNo = await getSNoCtrl();
    int nextSNo = salesNo + 1;

    await updateSalesNo(nextSNo);
    salesNo = await getSNoCtrl();
    return salesNo;
  }

  @override
  Future<int> nextSalesNumber() async {
    int nextSNo = 0;
    for (int i = 0; i < 5; i++) {
      int sNo = await getSalesNumber();
      if (sNo > 0) {
        nextSNo = sNo;
        break;
      }
    }
    return nextSNo;
  }

  @override
  Future<String> nextReceiptNumber() async {
    String nxtRcptNo = '';
    List<String> rcptNoData = <String>[];
    for (int i = 0; i < 5; i++) {
      rcptNoData = await getReceiptNumber(0, POSDtls.deviceNo);
      if (rcptNoData.isNotEmpty) {
        if (rcptNoData[1].isEmpty) {
          nxtRcptNo = rcptNoData[0];
        } else {
          throw ReceiptGenFailException('Receipt Header Full');
        }
      }
      break;
    }
    return nxtRcptNo;
  }
}

class ReceiptGenFailException implements Exception {
  ReceiptGenFailException(this.errMsg);

  final String errMsg;
}
